local inspect      = require 'spec.env.inspect'
local http         = require 'spec.env.http'
local sha          = require 'spec.env.sha'
local bucket       = require 'spec.env.bucket'
local Console      = require 'spec.env.console'
local send         = require 'spec.env.send'
local metric       = require 'spec.env.metric'
local time         = require 'spec.env.time'

local xml          = require 'lxp'   -- luarocks install LuaExpat
local cjson        = require 'cjson' -- luarocks install cjson
local mime         = require 'mime'  -- luarocks install luasocket

local env = {}

function env.new(spec)

  local base64 = { decode = mime.unb64,
                   encode = mime.b64 }

  local hmac = { sha256 = sha.hash256 }

  local console = Console.new()

  local trace = { link = "<trace_link>", time = 0 }

  local t = time.new(spec)
  local b = bucket.new(spec, t)
  local s = send.new(spec)
  local m = metric.new(spec)
  local h = http.new(spec)

  spec.trace = trace
  spec.time = t

  return {

    console          = console,
    inspect          = inspect,

    log              = print,
    base64           = base64,
    hmac             = hmac,
    trace            = trace,
    json             = cjson,
    xml              = xml,
    time             = t,
    bucket           = b,
    send             = s,
    metric           = m,
    http             = h
  }

end


return env
