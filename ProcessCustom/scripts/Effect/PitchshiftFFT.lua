
local menu_entry = "Pitch shift (FFT)"
local menu_group = "Effect"

-- thx to Stephan M. Bernsee
-- http://blogs.zynaptiq.com/bernsee/pitch-shifting-using-the-ft/
-- http://blogs.zynaptiq.com/bernsee/repo/smbPitchShift.cpp

local sample_rate = 44100

local process_buffer = nil

local phasor_freq = 4
local phasor_size = 40
local phasor_voices = 2

function InterpolateLinear(x0, x1, t)
  return (x0 * (1-t)) + (x1 * t)
end

function InterpolateHermite4pt3oX(x0, x1, x2, x3, t)
  local c0 = x1;
  local c1 = .5 * (x2 - x0);
  local c2 = x0 - (2.5 * x1) + (2 * x2) - (.5 * x3);
  local c3 = (.5 * (x3 - x0)) + (1.5 * (x1 - x2));
  return (((((c3 * t) + c2) * t) + c1) * t) + c0;
end

function get4pt(t, c)
  local x0 = 0
  if (t > 2 and t < process_buffer.number_of_frames+2) then 
    x0 = process_buffer:sample_data(c, math.floor(t) -1 ) 
  end

  local x1 = 0
  if (t > 1 and t < process_buffer.number_of_frames+1) then 
    x1 = process_buffer:sample_data(c, math.floor(t) ) 
  end

  local x2 = 0
  if (t > 0 and t < process_buffer.number_of_frames) then 
    x2 = process_buffer:sample_data(c, math.ceil(t) ) 
  end

  local x3 = 0
  if (t > -1 and t < process_buffer.number_of_frames-1) then 
    x3 = process_buffer:sample_data(c, math.ceil(t) +1 ) 
  end

  return InterpolateHermite4pt3oX(x0, x1, x2, x3, math.fmod(t,1))
end

local vb = renoise.ViewBuilder()
local semitones = vb:valuebox { min= -36, max= 36, value= 0 }
local cents = vb:valuebox { min= -100, max= 100, value= 0 }
local tightness = vb:valuebox { min= 10, max=4000, value=40 }
local smoothness = vb:valuebox { min= 1, max= 16, value=2 }
local view =  vb:row {
    margin= 8, spacing= 4,
    vb:text { text="semi-tones:" }, semitones,
    vb:text { text="cents:" }, cents,
    vb:text { text="thightness:" }, tightness,
    vb:text { text="smoothness:" }, smoothness
}

function init ()
  local sel = renoise.song().selected_sample
  process_buffer = sel.sample_buffer
  sample_rate = process_buffer.sample_rate

  local scale = math.pow(2, (semitones.value + (cents.value/100)) / 12)

  phasor_size = tightness.value
  phasor_voices = smoothness.value
  phasor_freq = (1 - scale) * 1000 / phasor_size
end

function main (index, input) 
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
      local val = get4pt(index - (phasor[v] * phasor_scale),  channel)
      out[channel] = out[channel] + ( val * declick[v] )
    end

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
