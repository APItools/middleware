local inspect      = require 'inspect'
local xml          = require 'lxp'
local http         = require 'http'
local sha          = require 'sha'
local Bucket       = require 'bucket'
local Console      = require 'console'

local mime         = require 'mime' -- provided by luasocket

local env = {}

function env.new()

  local base64 = { decode = mime.unb64,
                   encode = mime.b64 }

  local send = { emails = {}, events = {} }

  send.email = function(to, subject, message)
    send.emails[#send.emails + 1] = {to=to, subject=subject, message = message}
  end

  send.mail = send.email
  send.event = function(ev)
    send.events[#send.events + 1] = ev
  end

  send.notification = function(notification)
    notification.channel = 'middleware'
    send.event(notification)
  end

  local time =   { seconds = os.time,
                   http    = os.time,
                   now     = os.time }

  local bucket = { middleware = Bucket.new(),
                   service    = Bucket.new() }

  local hmac = { sha256 = sha.hash256 }

  local console = Console.new()

  local metric = { counts = {}, sets = {} }

  metric.count = function(name, inc)
    metric.counts[name] = (metric.counts[name] or 0) + (inc or 1)
  end

  metric.set = function(name, value)
    metric.sets[name] = value
  end

  return {

    console           = console,
    inspect           = inspect,

    -- just ngx.log
    log               = log,
    base64            = base64,
    hmac              = hmac,
    http              = safe_http,
    bucket            = bucket,
    send              = send,
    time              = time,
    metric            = metric,
    trace             = trace,
    json              = cjson,
    xml               = xml
  }

end


return env
