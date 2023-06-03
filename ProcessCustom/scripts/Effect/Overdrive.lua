
local menu_entry = "Overdrive"
local menu_group = "Effect"

-- page 72 : https://users.cs.cf.ac.uk/Dave.Marshall/CM0268/PDF/10_CM0268_Audio_FX.pdf

local thresh = 1/3

local function main (index, input)
  local out = table.create {}

  for i, v in pairs(input) do
    local vabs = math.abs(v)
    if vabs < thresh then           --1/3  double power, linear
      v = v * 2
    elseif vabs > 2*thresh then     --3/3  Soft Clip
      if v > 0 then
        v =  1
      else
        v = -1
      end
    elseif vabs >= thresh then      --2/3  Non-Linear (quadratic)
      if v > 0 then 
        v = (3-(2-v*3)^2)/3
      else
        v = -(3-(2-vabs*3)^2)/3
      end
    end
    out[i] = v
  end

  return out
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  main = main
}
