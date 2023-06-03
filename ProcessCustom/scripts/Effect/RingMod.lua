
local menu_entry = "Ring Modulation"
local menu_group = "Effect"

local vb = renoise.ViewBuilder()
local frequency = vb:valuebox { min= 1, max= 20000, value= 440.0 }
local amount = vb:valuebox { min = 0, max= 100, value= 50 }
local view =  vb:column {
  margin= 8, spacing= 4,
  vb:row { vb:text { width = 160, text="Frequency (Hz):" }, frequency },
  vb:row { vb:text { width = 160, text="Amount:" }, amount }
}

function main (index, input)
  local out = table.create {}
  local sel = renoise.song().selected_sample
  local buff = sel.sample_buffer
  local t = index / buff.sample_rate

  local mix = amount.value/100
  local carrier = math.sin(math.pi * 2 * t * frequency.value) * mix

  for i, v in pairs(input) do
    out[i] = (v * carrier) + (1-mix * v)
  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  view = view,
  main = main
}
