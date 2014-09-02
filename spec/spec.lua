package.path = package.path .. ";./middleware/?.lua"

require 'spec.assert_contains'

local env          = require 'spec.env.env'
local inspect      = require 'spec.inspect'
local sandbox      = require 'spec.sandbox'
local querystring  = require 'spec.querystring'
local url          = require 'socket.url' -- provided by luasocket

local spec = {}

local function same(t1,t2)
  local tt1, tt2 = type(t1), type(t2)
  if tt1 ~= tt2 then return false end
  if tt1 == 'table' then
    for k,v in pairs(t1) do
      if not same(v, t2[k]) then return false end
    end
    for k,v in pairs(t2) do
      if not same(v, t1[k]) then return false end
    end
    return true
  end
  return t1 == t2
end

local function copy_recursive(t)
  if type(t) ~= 'table' then return t end
  local c = {}
  for k,v in pairs(t) do
    c[copy_recursive(k)] = copy_recursive(v)
  end
  setmetatable(c, getmetatable(t))
  return c
end

local function complete_request(req)
  req = copy_recursive(req)

  local parseable_uri = req.url or req.uri_full or req.uri_relative or req.uri
  if parseable_uri then
    local info = url.parse(parseable_uri)
    req.scheme       = req.scheme       or info.scheme or 'http'
    req.host         = req.host         or info.host or 'localhost'
    req.uri          = (req.uri         or info.path):gsub('%?.*', '')
    req.query        = req.query        or info.query or ''
    req.args         = req.args         or querystring.parse(req.query)
    local has_query  = req.query == '' and '' or '?'
    req.uri_relative = req.uri_relative or (req.uri .. has_query .. req.query)
    req.uri_full     = req.uri_full     or (req.scheme .. '://' .. req.host .. req.uri_relative)
  else
    error("Invalid request: Must provide at least one of the following: url, uri, uri_full or uri_relative")
  end

  req.method  = req.method  or 'GET'
  req.headers = req.headers or {}
  req.body    = req.body    or ""

  return req
end

local function complete_response(res)
  res         = copy_recursive(res)

  res.status  = res.status  or 200
  res.body    = res.body    or 'ok (default body from spec.lua)'
  res.headers = res.headers or {}

  return res
end

------------------------------
spec.request = function(req)
  req = copy_recursive(req)

  local parseable_uri = req.url or req.uri_full or req.uri_relative or req.uri
  if parseable_uri then
    local info = url.parse(parseable_uri)
    req.scheme       = req.scheme       or info.scheme or 'http'
    req.host         = req.host         or info.host or 'localhost'
    req.uri          = (req.uri         or info.path):gsub('%?.*', '')
    req.query        = req.query        or info.query or ''
    req.args         = req.args         or querystring.parse(req.query)
    local has_query  = req.query == '' and '' or '?'
    req.uri_relative = req.uri_relative or (req.uri .. has_query .. req.query)
    req.uri_full     = req.uri_full     or (req.scheme .. '://' .. req.host .. req.uri_relative)
  else
    error("Invalid request: Must provide at least one of the following: url, uri, uri_full or uri_relative")
  end

  req.method  = req.method  or 'GET'
  req.headers = req.headers or {}
  req.body    = req.body    or ""

  return req
end

spec.next_middleware = function(next_middleware)
  return spy.new(function()
    return complete_response(next_middleware())
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
