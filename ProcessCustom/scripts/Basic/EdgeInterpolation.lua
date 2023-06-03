local menu_entry = "Edge Interpolation"
local menu_group = "Basic"

interpolate = require('lib.Interpolation')

function main (index, input) 
  local out = table.create {}

  for i, v in pairs(input) do
    out:insert( v )
  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  main = main
}
