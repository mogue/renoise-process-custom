
local menu_entry = "Sine Wave"
local menu_group = "Generate"

local vb = renoise.ViewBuilder()
local frequency = vb:valuebox { min= 1, max= 20000, value= 440.0 }
local view =  vb:column {
  margin= 8, spacing= 4,
  vb:row { vb:text { width = 160, text="Frequency (Hz):" }, frequency }
}

function main (index, input)
  local out = table.create {}
  local sel = renoise.song().selected_sample
  local buff = sel.sample_buffer
  local t = index / buff.sample_rate

  for i, v in pairs(input) do
    out[i] = math.sin(math.pi * 2 * t * frequency.value)
  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  view = view,
  main = main
}
