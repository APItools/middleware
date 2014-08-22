package.path = package.path .. ";./spec/env/?.lua;./middleware/?/?.lua"

local env     = require 'env'
local sandbox = require 'spec.sandbox'

local helper = {}

helper.run = function(middleware, request, expected_response)
  local environment     = env.new()
  local sandboxed_mw    = sandbox.protect(middleware, {env = environment})

  local next_middleware = function() return expected_response end
  local response        = sandboxed_mw(request, next_middleware)

  return response, environment
end

return helper
