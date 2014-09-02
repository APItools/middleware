require 'spec.assert_contains'

local env          = require 'spec.env.env'
local sandbox      = require 'spec.sandbox'
local http_utils   = require 'spec.env.http_utils'

local spec = {}

------------------------------
spec.request = function(req)
  return http_utils.complete_request(req)
end

spec.next_middleware = function(next_middleware)
  return spy.new(function()
    return http_utils.complete_response(next_middleware())
  end)
end

spec.middleware = function(path)
  for k,v in pairs(spec) do
    if type(v) ~= 'function' then spec[k] = nil end
  end

  local environment = env.new(spec)

  path = 'middleware/' .. path

  local loaded_f = assert(loadfile(path))
  local sandboxed_f = sandbox.protect(loaded_f, {env = environment})
  return sandboxed_f()
end

return spec
