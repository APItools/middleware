local bucket = {}


----------------------------------------

local Bucket = {}
local Bucket_methods = {}

function Bucket_methods:get(field_name)
  return self.values[field_name]
end

function Bucket_methods:set(field_name, value, exptime)
  self.values[field_name] = value
end

function Bucket_methods:delete(field_name)
  self.values[field_name] = nil
end

function Bucket_methods:incr(field_name, amount)
  self.values[field_name] = self.values[field_name] + (amount or 1)
end

function Bucket_methods:add(field_name, value, exptime)
  if self.values[field_name] then return false end
  self.values[field_name] = value
  return true
end

function Bucket_methods:get_keys()
  local keys = {}
  for k in pairs(self.values) do
    keys[#keys + 1] = k
  end
  return keys
end

----------------------------------------

local function bucketIndex(bucket, name)
  local method = Bucket_methods[name]
  if method then
    local f = function(...) return method(bucket, ...) end
    rawset(bucket, name, f)
    return f
  else
    return bucket.values[name]
  end
end

local Bucket_mt = { __index = bucketIndex }

function Bucket.new()
  return setmetatable({values = {}}, Bucket_mt)
end

---------------------------------------

function bucket.new(spec)
  local instance = spec.bucket or { middleware = Bucket.new(), service = Bucket.new() }
  spec.bucket = instance
  return instance
end

return bucket
