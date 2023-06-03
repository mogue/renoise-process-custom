-- Simple Filters by mogue
-- https://webaudio.github.io/Audio-EQ-Cookbook/Audio-EQ-Cookbook.txt
-- https://webaudio.github.io/Audio-EQ-Cookbook/audio-eq-cookbook.html
-- http://blog.bjornroche.com/2012/08/basic-audio-eqs.html

local menu_entry = "Filter"
local menu_group = "Effect"

local vb = renoise.ViewBuilder()
local ftype     = vb:popup { items = { "Low Pass", "High Pass", "Band Pass", "Band Stop", "All Pass", "EQ Peak", "Low Shelf", "High Shelf" } }
local freq      = vb:valuebox { min= 20, max= 10000, value= 440 }
local bandwidth = vb:valuebox { min= 0, max= 8, value= 2 }
local gain      = vb:valuebox { min= -100, max= 100, value= -20.0 }
local view = vb:column {
    margin= 8, spacing= 4,
    vb:row { vb:text { width = 160, text="Filter Type:" }, ftype },
    vb:row { vb:text { width = 160, text="Frequency:" }, freq },
    vb:row { vb:text { width = 160, text="Q:" }, bandwidth },
    vb:row { vb:text { width = 160, text="Gain:" }, gain },
}

local Fs, f0, BW, g
local A, sqrtA, w0, cosw0, sinw0, alpha
local b0, b1, b2, a0, a1, a2
local xmem1, xmem2, ymem1, ymem2

local coefficients = {
  -- LPF = Low Pass Filter
  function ()
    b0 =  (1 - cosw0)/2
    b1 =   1 - cosw0
    b2 =  (1 - cosw0)/2
    a0 =   1 + alpha
    a1 =  -2 * cosw0
    a2 =   1 - alpha
  end,
  -- HPF = High Pass Filter
  function ()
    b0 =  (1 + cosw0)/2
    b1 = -(1 + cosw0)
    b2 =  (1 + cosw0)/2
    a0 =   1 + alpha
    a1 =  -2 * cosw0
    a2 =   1 - alpha
  end,
  -- BPF = Band Pass Filter
  function ()
    b0 =   alpha
    b1 =   0
    b2 =  -alpha
    a0 =   1 + alpha
    a1 =  -2 * cosw0
    a2 =   1 - alpha
  end,
  -- notch = Band Stop Filter
  function ()
    b0 =   1
    b1 =  -2 * cosw0
    b2 =   1
    a0 =   1 + alpha
    a1 =  -2 * cosw0
    a2 =   1 - alpha
  end,
  -- APF = All Pass Filter
  function ()
    b0 =   1 - alpha
    b1 =  -2 * cosw0
    b2 =   1 + alpha
    a0 =   1 + alpha
    a1 =  -2 * cosw0
    a2 =   1 - alpha
  end,
  -- peakingEQ = Peaking EQ
  function ()
    b0 =   1 + alpha*A
    b1 =  -2 * cosw0
    b2 =   1 - alpha*A
    a0 =   1 + alpha/A
    a1 =  -2 * cosw0
    a2 =   1 - alpha/A
  end,
  -- lowShelf = Low Shelf EQ
  function ()
    b0 =    A*( (A+1) - (A-1)*cosw0 + 2*sqrtA*alpha )
    b1 =  2*A*( (A-1) - (A+1)*cosw0                 )
    b2 =    A*( (A+1) - (A-1)*cosw0 - 2*sqrtA*alpha )
    a0 =        (A+1) + (A-1)*cosw0 + 2*sqrtA*alpha
    a1 =   -2*( (A-1) + (A+1)*cosw0                 )
    a2 =        (A+1) + (A-1)*cosw0 - 2*sqrtA*alpha
  end,
  -- highShelf = High Shelf EQ
  function ()
    b0 =    A*( (A+1) + (A-1)*cosw0 + 2*sqrtA*alpha )
    b1 = -2*A*( (A-1) + (A+1)*cosw0                 )
    b2 =    A*( (A+1) + (A-1)*cosw0 - 2*sqrtA*alpha )
    a0 =        (A+1) - (A-1)*cosw0 + 2*sqrtA*alpha
    a1 =    2*( (A-1) - (A+1)*cosw0                 )
    a2 =        (A+1) - (A-1)*cosw0 - 2*sqrtA*alpha
  end,
}

local function init (sample_buffer)
  Fs    = sample_buffer.sample_rate
  f0    = freq.value
  BW    = bandwidth.value
  g     = gain.value

  A     = 10^(g/40)
  sqrtA = math.sqrt(A)
  w0    = 2 * math.pi * f0/Fs
  cosw0 = math.cos(w0)
  sinw0 = math.sin(w0)
  alpha = sinw0 * math.sinh( math.log(2)/2 * BW * w0/sinw0 )

  coefficients[ftype.value]()

  b0 = b0/a0
  b1 = b1/a0
  b2 = b2/a0
  a1 = a1/a0
  a2 = a2/a0

  xmem1, xmem2, ymem1, ymem2 = {0,0}, {0,0}, {0,0}, {0,0}
end

local function main (index, input)
  local out = table.create {}

  for ch, x in pairs(input) do
    out:insert( b0*x + b1*xmem1[ch] + b2*xmem2[ch] - a1*ymem1[ch] - a2*ymem2[ch] )
    xmem2[ch] = xmem1[ch]
    xmem1[ch] = x
    ymem2[ch] = ymem1[ch]
    ymem1[ch] = out[ch]
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