local s = require("say")
local ass = require("luassert")

local default_diff = 0.0001

local function difference(a,b, diff)
  diff = diff or default_diff
  if a == b then return true end
  local t1,t2 = type(a), type(b)
  if t1 ~= t2 then return false end

  if t1 == 'number' then
    return math.abs(a-b) < diff
  end
  return false
end

local function difference_for_luassert(state, arguments)
  return difference(arguments[1], arguments[2], arguments[3])
end

s:set("assertion.difference.positive", "Expected the difference between %s and %s to be smaller than %s")
s:set("assertion.difference.negative", "Expected the difference between %s and %s to NOT to be smaller than %s")

ass:register("assertion", "difference", difference_for_luassert, "assertion.difference.positive", "assertion.difference.negative")
