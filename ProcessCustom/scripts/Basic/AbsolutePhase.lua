local menu_entry = "Absolute Phase"
local menu_group = "Basic"

function main (index, input) 
  local out = table.create {}

  for i, v in pairs(input) do
    out:insert( math.abs(v) )
  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  main = main
}
