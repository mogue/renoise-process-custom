-- Pulse Wave Generation by mogue

local menu_entry = "Pulse Wave"
local menu_group = "Generate"

local vb = renoise.ViewBuilder()
local frequency  = vb:valuebox { min = 1, max = 20000, value = 440.0 }
local pulse_size = vb:valuebox { min = 1, max = 99, value = 50 }
local pwm_amount = vb:valuebox { min = 0, max = 100, value = 0 }
local pwm_freq   = vb:valuebox { min = 1, max = 20, value = 10 }
local view =  vb:column {
  margin= 8, spacing= 4,
  vb:row { vb:text { width = 160, text="Frequency (Hz):" }, frequency },
  vb:row { vb:text { width = 160, text="Pulse Size:" }, pulse_size },
  vb:text { width = 120, text = "Pulse Width Modulation:" },
  vb:row { vb:text { width = 160, text="Amount:" }, pwm_amount },
  vb:row { vb:text { width = 160, text="Frequency (ticks per cycle):" }, pwm_freq }
}

function main (index, input)
  local out = table.create {}
  local sel = renoise.song().selected_sample
  local buff = sel.sample_buffer
  local t = index / buff.sample_rate

  local mod_carrier = math.sin(math.pi * 2 * t / pwm_freq.value) * (pwm_amount.value / 100.0)

  local threshold = pulse_size.value / 100.0 + mod_carrier
  local phase = t * frequency.value % 1.0

  for i, v in pairs(input) do
    if phase < threshold then
      out[i] = -1
    else
      out[i] = 1
    end
  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  view = view,
  main = main
}