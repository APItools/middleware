local inspect     = require 'spec.env.inspect'
local http_utils  = require 'spec.env.http_utils'
local querystring = require 'spec.env.querystring'

local http = {}

local function same(a,b)
  local ta,tb = type(a), type(b)
  if ta ~= tb then return false end
  if ta ~= 'table' then return a == b end

  for k,v in pairs(a) do
    if not same(v, b[k]) then return false end
  end
  return true
end

local function get_mocked_response_for(req, spec)
  local http_mocks = spec.http_mocks or {}
  for i=1, #http_mocks do
    local http_mock = spec.http_mocks[i]
    if same(http_mock.request, req) then
      return http_mock.response
    end
  end
  error(("Attempted to make the http request:\n%s\nBut it was not found. Existing mocks: \n%s"):format(inspect(req), inspect(http_mocks)))
end

local function complete_request(req, body)
  req = type(req) == "string" and { url = req } or req
  req = http_utils.complete_request(req)

  if body then
    req.method = "POST"
    req.body = body
    req.headers["content-length"] = #body
  end

  if type(req.body) == "table" then
    req.body = querystring.encode(req.body)
    req.headers["Content-type"] = "application/x-www-form-urlencoded"
    req.headers["content-length"] = #req.body
  end

  return req
end

-- returns a table instead of 3 elements, like http.simple, which is bonkers
local function sane_simple(req, body, spec)
  req = complete_request(req, body)
  return get_mocked_response_for(req, spec)
end

--

function http.new(spec)
  local instance = {}

  instance.simple = function(req, body)
    local res = sane_simple(req, body, spec)
    return res.body, res.status, res.header
  end

  instance.multi = function(reqs)
    local result = {}
    for i=1, #reqs do
      result[i] = sane_simple(reqs[i], nil, spec)
    end
    return result
  end

  instance.is_success = function(status)
    return status >= 200 and status < 300
  end

  return instance
end

return http
