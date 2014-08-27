package.path = package.path .. ";./middleware/?.lua"

local env          = require 'spec.env.env'
local inspect      = require 'spec.inspect'
local sandbox      = require 'spec.sandbox'
local querystring  = require 'spec.querystring'
local url          = require 'socket.url' -- provided by luasocket

local helper = {}

helper.run = function(middleware, request, expected_response, environment)
  environment = environment or env.new()

  local sandboxed_mw    = sandbox.protect(middleware, {env = environment})
  local next_middleware = function() return expected_response end
  local response        = sandboxed_mw(request, next_middleware)

  return response, environment
end

return helper
