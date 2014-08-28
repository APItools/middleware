package.path = package.path .. ";./middleware/?.lua"

local env          = require 'spec.env.env'
local inspect      = require 'spec.inspect'
local sandbox      = require 'spec.sandbox'
local querystring  = require 'spec.querystring'
local url          = require 'socket.url' -- provided by luasocket

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

local function complete_backend_response(res)
  res         = copy_recursive(res)

  res.status  = res.status  or 200
  res.body    = res.body    or 'ok (default body from spec.lua)'
  res.headers = res.headers or {}

  return res
end


local Expectation = {}
local Expectation_mt = {__index = Expectation}

function Expectation:called_with(request, backend_response)
  backend_response = backend_response or {}
  request          = complete_request(request)

  self.request          = copy_recursive(request) -- we need the *initial* request here, not a reference
  self.backend_response = complete_backend_response(backend_response)
  self.env              = self.env or env.new()

  local next_middleware = function()
    self.request_to_backend = copy_recursive(request) -- copy the request as it is when it enters next_middleware
    return self.backend_response
  end

  local sandboxed_f   = sandbox.protect(self.middleware_f, {env = self.env})
  self.response       = sandboxed_f(request, next_middleware)

  return self
end

function Expectation:to_pass(expected_request_to_backend)
  for k,v in pairs(expected_request_to_backend) do
    if type(v) == 'table' then
      assert.same(v, self.request_to_backend[k])
    else
      assert.equal(v, self.request_to_backend[k])
    end
  end

  return self
end

function Expectation:to_receive(expected_backend_response)
  for k,v in pairs(expected_backend_response) do
    if type(v) == 'table' then
      assert.same(v, self.backend_response[k])
    else
      assert.equal(v, self.backend_response[k])
    end
  end

  return self
end

function Expectation:to_return(expected_returned_response)
  for k,v in pairs(expected_returned_response) do
    if type(v) == 'table' then
      assert.same(v, self.response[k])
    else
      assert.equal(v, self.response[k])
    end
  end

  return self
end

function Expectation:to_set_number_of_keys_in_middleware_bucket(n)
  assert.same(#self.env.bucket.middleware.get_keys(), n)
  return self
end

function Expectation:to_set_in_middleware_bucket(key, value)
  if value == nil then
    assert.not_nil(self.env.bucket.middleware.values[key])
  else
    assert.equal(self.env.bucket.middleware.values[key], value)
  end
  return self
end

function Expectation:to_send_number_of_emails(n)
  assert.equal(#self.env.send.emails, n)
  return self
end

function Expectation:to_send_email(to, subject, message)
  local emails = self.env.send.emails
  for i=1, #emails do
    local email = emails[i]
    if email.to == to and email.subject == subject and email.message == message then return self end
  end
  error(('The email to: %s with subject "%s" and message "%s" was not sent. Emails: %s'):format(
    to, subject, message, inspect(emails)
  ))
end

function Expectation:to_send_number_of_events(n)
  assert.equal(#self.env.send.events, n)
  return self
end

function Expectation:to_send_event(t)
  local events = self.env.send.events
  for i=1, #events do
    if same(t, events[i]) then return self end
  end
  error(('The event %s was not sent. Events: %s'):format(inspect(t), inspect(events)))
end

local expect = function(middleware_f)
  return setmetatable({ middleware_f = middleware_f}, Expectation_mt)
end

return expect
