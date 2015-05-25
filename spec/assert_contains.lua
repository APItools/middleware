local s = require("say")
local ass = require("luassert")

local function contains(container, contained)
  if container == contained then return true end
  local t1,t2 = type(container), type(contained)
  if t1 ~= t2 then return false end

  if t1 == 'table' then
    for k,v in pairs(contained) do
      if not contains(container[k], v) then return false end
    end
    return true
  end
  return false
end

local function contains_for_luassert(state, arguments)
  return contains(arguments[1], arguments[2])
end

s:set("assertion.contains.positive", "Expected %s\n to contain \n%s")
s:set("assertion.contains.negative", "Expected %s\n to NOT contain \n%s")

ass:register("assertion", "contains", contains_for_luassert, "assertion.contains.positive", "assertion.contains.negative")
