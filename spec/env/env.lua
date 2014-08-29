local inspect      = require 'spec.inspect'
local xml          = require 'lxp'
local http         = require 'spec.env.http'
local sha          = require 'spec.env.sha'
local bucket       = require 'spec.env.bucket'
local Console      = require 'spec.env.console'
local send         = require 'spec.env.send'
local metric       = require 'spec.env.metric'

local mime         = require 'mime' -- provided by luasocket

local env = {}

function env.new(spec)

  local base64 = { decode = mime.unb64,
                   encode = mime.b64 }

  local time =   { seconds = os.time,
                   http    = os.time,
                   now     = os.time }

  local hmac = { sha256 = sha.hash256 }

  local console = Console.new()

  local trace = { link = "<trace_link>" }

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
    http              = safe_http,
    time              = time,
    trace             = trace,
    json              = cjson,
    xml               = xml,
    bucket            = b,
    send              = s,
    metric            = m,
  }

end


return env
