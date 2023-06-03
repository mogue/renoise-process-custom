-- Based on C++ Voss algorithm by Thomas Hudson, 1998
-- https://www.firstpr.com.au/dsp/pink-noise/
-- according to the discussion this is not perfect but good enough, sounds ok :)

local menu_entry = "Pink Noise"
local menu_group = "Noise"

-- parameters
local layers =  8

-- initialized values
local max_key
local key
local white_values

local function init (sample_buffer)
  max_key = 0xFF -- bit for each layer
  key = 0
  white_values = table.create {}
  for i = 1, 1+layers, 1 do
    white_values:insert(
      (math.random() * 2) - 1
    )
  end
end

local function main (index, input)
  local out = table.create {}

  local sum
  local last_key
  local diff

  for c = 1, #input do
    last_key = key
    key = key + 1
    if key > max_key then
      key = 0
    end

    diff = bit.bxor(last_key, key)
    sum = 0

    for i = 1, 1+layers, 1 do
      if bit.band(diff, bit.lshift(1, i-1)) > 0 then
        white_values[i] = (math.random() * 2) - 1
      end
      sum = sum + white_values[i]
    end

    out:insert( sum / layers )
  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  init = init,
  main = main
}
