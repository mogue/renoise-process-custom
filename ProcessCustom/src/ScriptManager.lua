--[[============================================================================
src/ScriptManager.lua
============================================================================]]--

SnippetMain = require('src.SnippetMain')
Preferences = require('src.Preferences')

local use_seperate_menu_entry = false

--------------------------------------------------------------------------------
-- helpers
--------------------------------------------------------------------------------

local function format_menu_entry(sets, script_id)
  if type(sets) == "userdata" or not sets.menu_entry then
    renoise.app():show_warning("No menu entry set for script: " .. script_id)
    return false
  end

  local crumb = "Sample Editor:Mogue Process:"
  if (use_seperate_menu_entry) then crumb = "Sample Editor:Process:" end
  if (sets.menu_group) then crumb = crumb .. sets.menu_group .. ":" end
  crumb = crumb .. sets.menu_entry
  return crumb
end

local function unload_scripts()
  local loaded = package.loaded["scripts.available_scripts"]
  for i, name in ipairs(loaded) do
    local scr = package.loaded["scripts." .. name ]
    if scr then
      local e = format_menu_entry(scr, name)
      if e then
        renoise.tool():remove_menu_entry(e)
      end
      package.loaded["scripts." .. name ] = nil
    end
  end
  package.loaded["scripts.available_scripts"] = nil
end

local function load_scripts()
  local script_list = require "scripts.available_scripts"

  for i, script_id in ipairs(script_list) do
    local status, sets = pcall( require, "scripts." .. script_id)
    if status == true then
      local crumb = format_menu_entry(sets, script_id)
      if crumb then
        renoise.tool():add_menu_entry {
          name = crumb,
          invoke = function ()
            SnippetMain.run(sets)
          end
        }
      else
        renoise.app():show_warning("Missing menu entry: " .. script_id)
      end
    else
      renoise.app():show_warning("Failed to load script: " .. script_id)
    end
  end
end

--------------------------------------------------------------------------------
-- menu registration
--------------------------------------------------------------------------------

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Custom Sample Process:Open Scripts Folder ...",
  invoke = function () 
    renoise.app():open_path("scripts")
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Custom Sample Process:Settings ...",
  invoke = function ()
    Preferences.guiSettings()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Custom Sample Process:Use separate menu entry",
  invoke = function ()
    unload_scripts()
    if use_seperate_menu_entry then
      use_seperate_menu_entry = false
    else
      use_seperate_menu_entry = true
    end
    load_scripts()
  end,
  selected = function () return use_seperate_menu_entry end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Custom Sample Process:Reload scripts",
  invoke = function ()
    unload_scripts()
    load_scripts()
  end
}

return {
    load_scripts = load_scripts
}