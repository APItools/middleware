local buckets = {}

local Bucket = {}

----------------------------------------
local Bucket_methods = {}

local function get_id(self)
  return getmetatable(self).id
end

local function get_key(self, field_name)
  return get_id(self) .. "/" .. field_name
end

function Bucket_methods:get(field_name)
  local key = get_key(self, field_name)
  return buckets[key]
end

function Bucket_methods:set(field_name, value, exptime)
  local key   = get_key(self, field_name)
  bukets[key] = value
end

function Bucket_methods:delete(field_name)
  local key = get_key(self, field_name)
  buckets[key] = nil
end

function Bucket_methods:incr(field_name, amount)
  amount = amount or 1
  local key = get_key(self, field_name)
  buckets[key] = buckets[key] + 1
end

function Bucket_methods:add(field_name, value, exptime)
  exptime = exptime or 0
  local key     = get_key(self, field_name)
  if buckets[key] then return false end
  buckets[key] = value
  return true
end

function Bucket_methods:delete_all()
  buckets = {}
end

function Bucket_methods:get_keys()
  local result, len = {}, 0
  for k,_ in pairs(buckets) do
    len = len + 1
    result[len] = k
  end
  return result
end

----------------------------------------

local function makeDotMethod(bucket, name)
  local method = Bucket_methods[name]
  if method then
    local f = function(...) return method(bucket, ...) end
    rawset(bucket, name, f)
    return f
  end
end

function Bucket.for_middleware(service_id, middleware_uuid)
  return setmetatable({}, {
    id      = 'mw/' .. tostring(service_id) .. '.' .. tostring(uuid),
    __index = makeDotMethod
  })
end

function Bucket.for_service(service_id)
  return setmetatable({}, {
    id      = 's/' .. tostring(service_id),
    __index = makeDotMethod
  })
end

return Bucket
