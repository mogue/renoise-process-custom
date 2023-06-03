local menu_entry = "Flanger"
local menu_group = "Effect"

Interpolate = require("lib.Interpolation")

local vb = renoise.ViewBuilder()
local rate_ticks      = vb:valuebox { min= 1, max= 20000, value= 24 }
local depth_samples   = vb:valuebox { min= 1, max= 9999,  value= 64 }

local view = vb:column {
  margin= 8, spacing= 4,
  vb:row { vb:text { width = 160, text="Rate (ticks):"  }, rate_ticks  },
  vb:row { vb:text { width = 160, text="Depth (samples):" }, depth_samples }
}

local retained_buffer = nil
local sample_rate = 44100.
local cursor      = 0
local frequency   = 0
local amount      = 0

local amp = 0.7

function init(sample_buffer)
  local transport = renoise.song().transport
  retained_buffer = sample_buffer
  sample_rate     = sample_buffer.sample_rate
  cursor          = sample_buffer.selection_start
  --                ticks per second / nr_of_ticks = Hz
  frequency       = (transport.tpl * transport.lpb * transport.bpm / 60.) / rate_ticks.value
  amount          = depth_samples.value
end

function main (index, input)
  local out = table.create {}
  cursor = cursor + 1

  local t = cursor / sample_rate
  local lfo = math.sin(math.pi * 2 * t * frequency) * amount

  for channel, v in pairs(input) do
    out[channel] = (v*amp) + (Interpolate.BufferHermite(retained_buffer, channel, index + lfo)*amp)
  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  view = view,
  init = init,
  main = main
}
