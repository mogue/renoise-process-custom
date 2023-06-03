
local menu_entry = "White Noise"
local menu_group = "Noise"

function main (index, input) 
  local out = table.create {}

  for c = 1, #input do
    out:insert( (math.random() * 2) - 1 )
  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  main = main
}
