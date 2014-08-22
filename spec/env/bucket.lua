local Bucket = {}

----------------------------------------
local Bucket_methods = {}

function Bucket_methods:get(field_name)
  return self[field_name]
end

function Bucket_methods:set(field_name, value, exptime)
  self[field_name] = value
end

function Bucket_methods:delete(field_name)
  self[field_name] = nil
end

function Bucket_methods:incr(field_name, amount)
  self[field_name] = self[field_name] + (amount or 1)
end

function Bucket_methods:add(field_name, value, exptime)
  if self[field_name] then return false end
  self[field_name] = value
  return true
end

function Bucket_methods:get_keys()
  local keys = {}
  for k in pairs(self) do
    keys[#keys + 1] = k
  end
  return keys
end

----------------------------------------

local function makeDotMethod(bucket, name)
  local method = Bucket_methods[name]
  if method then
    return function(...) return method(bucket, ...) end
  end
end

local Bucket_mt = { __index = makeDotMethod }

function Bucket.new()
  return setmetatable({}, Bucket_mt)
end

return Bucket
