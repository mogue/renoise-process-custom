
local menu_entry = "Brown Noise"
local menu_group = "Noise"

-- https://github.com/RoryWatts/Just-Brown-Noise/blob/main/index.html
-- c and v control "color" of the noise - v=1.0 is white, v=0.025 is brown-ish
local v = 0.025    -- variation i.e. how much of next sample is random
local c = 1.0 - v  -- color i.e. how much of the next sample is contributed by the last

local last = { 0, 0 }

local function main (index, input)
  local out = table.create {}

  for ch = 1, #input do
    out:insert( last[ch] * c + (math.random() * 2 - 1) * v )
  end
  last = out

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  main = main
}
