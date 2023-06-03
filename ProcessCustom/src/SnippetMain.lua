--[[============================================================================
src/SnippetMain.lua
============================================================================]]--

local window_size     = 4410

local current_snippet = nil
local current_buffer  = nil
local temp_buffer     = table.create {}
local current_index   = 1
local start_index     = 1
local stop_index      = 1
local do_channels     = table.create {}

local progress_view   = renoise.ViewBuilder():row { margin = 12 }
local progress        = renoise.ViewBuilder():text { text = "0%", font= "big", width = "100%", align = "center" }
progress_view:add_child(progress)
local progress_dialog = nil

--[[============================================================================

Snippet =
{
    menu_entry  = string Menu Name of Snippet
    menu_group  = string Menu Group of Snippet
    view        = ViewBuilder object (optional) for the Snippet options interface
    validate    = function (optional) Make checks and return true/false before running the Snippet
    init        = function (optional) Run before sample process.
    main        = function (optional) Run for each sample as a background process in window size batches
    post        = function (optional) Run after the main process before writing to the sample_buffer
}

============================================================================]]--

local function SnippetStart (snip)
  -- Clear if last snippet didn't exit properly.
  if ( renoise.tool().app_idle_observable:has_notifier(SnippetRunFrame) ) then
    renoise.tool().app_idle_observable:remove_notifier(SnippetRunFrame)
  end

  local sel = renoise.song().selected_sample
  if ( not sel ) then
    local inst = renoise.song().selected_instrument
    if inst.name == '' then
        inst.name = snip.menu_entry
    end
    inst:insert_sample_at(1)
    sel = renoise.song().selected_sample
    sel.name = snip.menu_entry
  end

  local buff = sel.sample_buffer
  if ( not buff.has_sample_data ) then
    buff:create_sample_data(
        44100, 16, 2,
        44100 * 2.0
    )
  end

  current_snippet = snip
  current_buffer = buff

  if (snip.validate) then 
    if (snip.validate(current_buffer) ~= true) then
      return false
    end
  end

  if (snip.view) then 
    local accept = renoise.app():show_custom_prompt(snip.menu_entry, snip.view, { "Process", "Cancel" })
    if (accept ~= "Process") then
      return false
    end
  end

  temp_buffer = table.create {}

  if (snip.init) then snip.init(current_buffer) end

  start_index = 1
  stop_index = current_buffer.number_of_frames

  do_channels = {}
  if (current_buffer.selection_range) then
    start_index = current_buffer.selection_start
    stop_index = current_buffer.selection_end

    local selected_ch = current_buffer.selected_channel
    if selected_ch == 1 or selected_ch == 3 then
      table.insert(do_channels, 1)
    end
    if selected_ch == 2 or selected_ch == 3 then
      table.insert(do_channels, 2)
    end
  else
    for c = 1, current_buffer.number_of_channels do
      table.insert(do_channels, c)
    end
  end

  current_index = start_index

  progress_dialog = renoise.app():show_custom_dialog( snip.menu_entry, progress_view )

  if ( not renoise.tool().app_idle_observable:has_notifier(SnippetRunFrame) and snip.main ) then
    renoise.tool().app_idle_observable:add_notifier(SnippetRunFrame)
  end
end

function SnippetRunFrame ()
  if (not progress_dialog.visible) then
    SnippetFinish()
    renoise.app():show_warning(current_snippet.menu_entry .. " was canceled.")
--  renoise.song():undo() -- Not needed as Finish checks for the dialog, but technical completeness 
    return
  end
  local len = math.min(window_size, stop_index-current_index)
  for s = current_index, current_index+len do
    local v = table.create {}
    for c = 1, #do_channels do
      v:insert( current_buffer:sample_data(do_channels[c], s) )
    end
    v = current_snippet.main(s, v)
    temp_buffer:insert(v)
    if (current_index >= stop_index) then
      SnippetFinish()
    end
    current_index = current_index + 1
  end
  progress.text = math.floor( (current_index/stop_index)*100 ) .. '% '
end

function SnippetFinish()
  if ( renoise.tool().app_idle_observable:has_notifier(SnippetRunFrame) ) then
    renoise.tool().app_idle_observable:remove_notifier(SnippetRunFrame)
  end

  if (current_snippet.post) then current_snippet.post(current_buffer) end

  if (progress_dialog.visible) then
    progress_dialog:close()
    current_buffer:prepare_sample_data_changes()
    for f = start_index, stop_index do
      for c = 1, #do_channels do
        current_buffer:set_sample_data(do_channels[c], f, temp_buffer[f-start_index+1][c])
      end
    end
    current_buffer:finalize_sample_data_changes()
  end

  current_buffer = nil
  current_snippet = nil
end

return {
    run = SnippetStart,
}