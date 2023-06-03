-- Simple Granulizer by mogue

local menu_entry = "Granulizer"
local menu_group = "Effect"

local vb = renoise.ViewBuilder()
-- local curve       = vb:popup { items = { "atan", "tanh"} }
local grain_count = vb:valuebox { min= 1, max= 1000, value= 10 }
local grain_size  = vb:valuebox { min= 1, max= 10000, value= 500 }
local view = vb:column {
    margin= 8, spacing= 4,
    vb:row { vb:text { width = 160, text="Grains:" },     grain_count },
    vb:row { vb:text { width = 160, text="Grain Size:" }, grain_size },
}

local grains = {}

function pre ()
  local distribution = grain_size.value / grain_count.value

  for i = 0, grain_count.value, 1 do
    grains:insert({
      counter = i * distribution,
      offset  = math.random()
    })
  end
end

function main (index, input) 
  local out = table.create {}
  local vol = volume.value / 100.

  for channel, v in pairs(input) do
    out:insert( vol * math.atan(v * gain.value) )
  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  init = pre,
  main = main,
  view = view
}
