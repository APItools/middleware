require 'spec.assert_contains'

local env          = require 'spec.env.env'
local sandbox      = require 'spec.sandbox'
local http_utils   = require 'spec.env.http_utils'

local spec = {}

------------------------------
spec.request = function(req)
  return http_utils.complete_request(req)
end

spec.next_middleware = function(f)
  return spy.new(function()
    local start = spec.time.now()
    local response = http_utils.complete_response(f())
    spec.trace.time = spec.time.now() - start
    return response
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

spec.mock_http = function(request, response)
  local mocks = spec.http_mocks or {}
  spec.http_mocks = mocks

  mocks[#mocks + 1] = {
    request = http_utils.complete_request(request),
    response = http_utils.complete_response(response)
  }
end

spec.advance_time = function(seconds)
  spec.now = spec.now or spec.time.seconds()
  spec.now = spec.now + seconds
end

return spec
