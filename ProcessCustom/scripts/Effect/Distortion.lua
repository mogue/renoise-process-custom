-- Simple Distortion by mogue
-- https://kidpatel.wixsite.com/dspaudioeffects/distortion

local menu_entry = "Distortion"
local menu_group = "Effect"

local vb = renoise.ViewBuilder()
local curve = vb:popup { items = { "atan", "tanh", "exp" } }
local volume = vb:valuebox { min= 0, max= 100, value= 50 }
local gain = vb:valuebox { min= 0, max= 1000, value= 20.0 }
local view =  vb:column {
    margin= 8, spacing= 4,
    vb:row { vb:text { width = 160, text="Curve:" }, curve },
    vb:row { vb:text { width = 160, text="Input Gain:" }, gain },
    vb:row { vb:text { width = 160, text="Output Volume (0-100%):" }, volume }
}

local vol, curve_fn

local curve_fns = {
  -- atan
  function (v)
    return vol * math.atan(v * gain.value)
  end,
  -- tanh
  function (v)
    return vol * math.tanh(v * gain.value)
  end,
  -- exponent
  function (v)
    if v == 0 then return 0 end
    return vol * (v / math.abs(v)) * ( 1 - math.exp( gain.value * ((v*v)/math.abs(v)) ) )
  end
}

local function init (sample_buffer)
  vol = volume.value / 100.
  curve_fn = curve_fns[curve.value]
end

local function main (index, input)
  local out = table.create {}

  for i, v in pairs(input) do
    out:insert( curve_fn(v) )
  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  init = init,
  main = main,
  view = view
}
