
local menu_entry = "Cycle Samples"
local menu_group = "Basic"

local process_buffer = nil

local current_duty
local current_size
local  buffer_size

local vb = renoise.ViewBuilder()
local duty = vb:valuebox { min= 0, max= 100, value= 50 }
local view =  vb:row {
    margin= 8, spacing= 4,
    vb:text { text="Percentage:" },
    duty
}

function pre (sample_buffer)
  process_buffer = sample_buffer

  buffer_size = process_buffer.number_of_frames
  current_duty = duty.value
end

function main (index, input)
  local out = table.create {}
  local i = 0

  current_size = buffer_size * current_duty

--  if (index < current_size) then
    for channel, data in pairs(input) do
      i = i + 1
      out[channel] = process_buffer:sample_data(channel, i + current_size % buffer_size)
    end
--  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  pre  = pre,
  main = main,
  view = view
}
