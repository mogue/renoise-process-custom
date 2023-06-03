
local menu_entry = "Violet Noise"
local menu_group = "Noise"

-- thx to bjorn-nesby : https://github.com/renoise/cLib/blob/master/classes/cWaveform.lua#L90

local previous = table.create { 0, 0 }

function main (index, input) 
  local out = table.create {}
  local random = 0

  for c = 1, #input do

    random = (math.random() * 2) - 1

    out:insert( (random - previous[c]) / 2 )

    previous[c] = random

  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  main = main
}
