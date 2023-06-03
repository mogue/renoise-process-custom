
local menu_entry = "Pitch Shift (Robotic)"
local menu_group = "Effect"

Interpolate = require('lib.Interpolation')

local sample_rate    = 44100
local process_buffer = nil
local phasor_freq    = 4
local phasor_size    = 40
local phasor_voices  = 2

local vb = renoise.ViewBuilder()
local semitones  = vb:valuebox { min= -128, max= 128,  value= 7   }
local cents      = vb:valuebox { min= -100, max= 100,  value= 0   }
local tightness  = vb:valuebox { min= 10,   max= 4000, value= 100 }
local smoothness = vb:valuebox { min= 1,    max= 16,   value= 2   }
local view =  vb:column {
    margin= 8, spacing= 4,
    vb:row { vb:text { width = 160, text="Pitch:"      }, semitones  },
    vb:row { vb:text { width = 160, text="Finetune:"   }, cents      },
    vb:row { vb:text { width = 160, text="Tightness:"  }, tightness  },
    vb:row { vb:text { width = 160, text="Smoothness:" }, smoothness }
}

local function init (current_buffer)
  process_buffer = current_buffer
  sample_rate = current_buffer.sample_rate

  local scale = math.pow(2, (semitones.value + (cents.value/100)) / 12)

  phasor_size = tightness.value
  phasor_voices = smoothness.value
  phasor_freq = (1 - scale) * 1000 / phasor_size
end

local function main (index, input)
  local out = table.create {}
  local t = index / sample_rate

  local phasor = table.create {}
  local declick = table.create {}

  phasor[1] = math.fmod(t * phasor_freq, 1)
  if phasor[1] < 0 then phasor[1] = 1 + phasor[1] end

  for v = 1, phasor_voices do
    if (v > 1) then
      phasor[v] = math.fmod( ( phasor[v-1] + (1/phasor_voices) ), 1 )
    end
    declick[v] = math.cos( (phasor[v] - 0.5) * math.pi)
  end

  local phasor_scale = phasor_size * (sample_rate/1000)

  for channel, v in pairs(input) do
    out[channel] = 0
    for v = 1, phasor_voices do
      local val = Interpolate.BufferHermite(process_buffer, channel, index - (phasor[v] * phasor_scale))
      out[channel] = out[channel] + ( val * declick[v] )
    end
    out[channel] = out[channel] / phasor_voices -- to much volume drop, need a better normalizer
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