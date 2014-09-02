local inspect      = require 'spec.env.inspect'
local http         = require 'spec.env.http'
local sha          = require 'spec.env.sha'
local bucket       = require 'spec.env.bucket'
local Console      = require 'spec.env.console'
local send         = require 'spec.env.send'
local metric       = require 'spec.env.metric'

local xml          = require 'lxp'   -- luarocks install LuaExpat
local cjson        = require 'cjson' -- luarocks install cjson
local mime         = require 'mime'  -- luarocks install luasocket

local env = {}

function env.new(spec)

  local base64 = { decode = mime.unb64,
                   encode = mime.b64 }

  local time =   { seconds = os.time,
                   -- avoid warnings when passing params
                   http    = function() return os.time() end,
                   now     = os.time }

  local hmac = { sha256 = sha.hash256 }

  local console = Console.new()

  local trace = { link = "<trace_link>" }

  local h = http.new(spec)
  local b = bucket.new(spec)
  local s = send.new(spec)
  local m = metric.new(spec)

  return {

    console           = console,
    inspect           = inspect,

    -- just ngx.log
    log               = log,
    base64            = base64,
    hmac              = hmac,
    time              = time,
    trace             = trace,
    json              = cjson,
    xml               = xml,
    http              = h,
    bucket            = b,
    send              = s,
    metric            = m
  }

end


return env
