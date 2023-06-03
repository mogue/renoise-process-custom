local menu_entry = "Arithmetic Mix"
local menu_group = "Basic"

local arithmetics = {
  -- 1 Sum
  function (a, b)
    return a + b
  end,
  -- 2 Difference
  function (a, b)
    return a - b
  end,
  -- 3 Multiply
  function (a, b)
    return a * b
  end,
  -- 4 Division
  function (a, b)
    return a / b
  end
}

local vb = renoise.ViewBuilder()
local arith_symbol = vb:popup { items = { "+", "-", "*", "/" } }
local view =  vb:row {
    margin= 8, spacing= 4,
    vb:text { text="Mix Operation:" },
    arith_symbol
}

function validate (sample_buffer)
  if sample_buffer.number_of_channels == 2 then
    return true
  end
  renoise.app():show_error("Requires a stereo sample buffer.")
  return false
end

function main (index, input) 
  local out = table.create {}
  local v = arithmetics[arith_symbol.value](input[1], input[2])
  out:insert( v )
  out:insert( v )
  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  validate = validate,
  main = main,
  view = view
}
