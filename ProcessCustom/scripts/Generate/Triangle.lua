
local menu_entry = "Triangle / Saw"
local menu_group = "Generate"

local vb = renoise.ViewBuilder()
local freq   = vb:valuebox { min= 20, max= 20000, value=440 }
local angle  = vb:valuebox { min= 0,  max= 100,   value= 50 }

local view = vb:column {
  margin= 8, spacing= 4,
  vb:row { vb:text { width = 160, text="Note Frequency:" }, freq },
  vb:row { vb:text { width = 160, text="Angle:" },          angle },
}

local sample_rate, threshold, ramp_up, ramp_down

function pre ()
  sample_rate = renoise.song().selected_sample.sample_buffer.sample_rate
  threshold = angle.value / 50.
  ramp_up = 2. / threshold
  ramp_down =  2. / (2. - threshold)
end

function main (index, input)
  local out = table.create {}
  local t = index / sample_rate

  local phase = t * freq.value % 2

  for i, v in pairs(input) do
    if phase < threshold then
      out[i] = phase * ramp_up - 1.
    else
      out[i] = (2. - phase) * ramp_down - 1.
    end
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