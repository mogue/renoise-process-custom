
local menu_entry = "Super Saw"
local menu_group = "Generate"

local vb = renoise.ViewBuilder()
local freq   = vb:valuebox { min= 20, max= 20000, value=440 }
local order  = vb:valuebox { min= 1, max= 64, value= 1 }
local detune = vb:valuebox { min= 1, max= 400, value= 10 }
local phase  = vb:valuebox { min= 0, max= 100, value= 50 }
local rng    = vb:valuebox { min= 0, max= 100, value= 0 }
local blend  = vb:valuebox { min= 0, max= 100, value= 50 }

local view = vb:column {
  margin= 8, spacing= 4,
  vb:row { vb:text { width = 160, text="Note Frequency:" }, freq },

  vb:row { vb:text { width = 160, text="Super Saw:" } },
  vb:row { vb:text { width = 160, text="Order:" },            order },
  vb:row { vb:text { width = 160, text="Detune (cents):" },   detune },
  vb:row { vb:text { width = 160, text="Phase: " },           phase },
  vb:row { vb:text { width = 160, text="Variation: " },       rng },
  vb:row { vb:text { width = 160, text="Blend: "},            blend }
}

function main (index, input)
  local out = table.create {}
  local sel = renoise.song().selected_sample
  local buff = sel.sample_buffer
  local t = index / buff.sample_rate

  local phase = 1 - (t * freq.value % 2)

  for i, v in pairs(input) do
    out[i] = phase

    local c_blend = blend.value / 100.
    for o = 1,order.value-1,1 do
      local size = (detune.value * o) / 1200.
      local high = 1 - (freq.value * math.pow(2, size) * t % 1 * 2)
      local low  = 1 - (freq.value * math.pow(2, -size) * t % 1 * 2)
--      distance = freq.value * math.pow(2, -size)
      out[i] = out[i] + (high + low * c_blend)

      c_blend = c_blend * c_blend
    end

    out[i] = out[i] / (order.value * 4)
  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  main = main,
  view = view
}