local inspect = require 'inspect'
local Model   = require 'model'

local Trace = Model:new()

function Trace:new()

  local query   = ngx.var.query_string or ""
  local scheme  = ngx.var.scheme
  local host    = ngx.var.host

  local uri = ngx.var.request_uri:gsub('%?.*', '')
  -- uri_relative = /test?arg=true
  local uri_relative  = uri .. ngx.var.is_args .. query
  -- uri_full = http://example.com/test?arg=true
  local uri_full      =  scheme .. '://' ..  host .. uri_relative

  return {
    req = {
      query         = query,
      uri_full      = uri_full,
      uri_relative  = uri_relative,
      method        = ngx.var.request_method,
      args          = ngx.req.args,
      scheme        = scheme,
      uri           = uri,
      host          = host
    }
  }
end

function Trace:async_save(trace, f)
  f()
end

function Trace:setRes(trace, res)
  trace.res = {
    status = res.status,
    body   = res.body,
    headers = {}
  }
  if type(res.headers) == 'table' then
    for k,v in pairs(res.headers) do trace.res.headers[k] = v end
  end
  print('Saving trace: ', inspect(trace))
end

function Trace:setError(trace, err)
  trace['error'] = tostring(err)
  print('Error in trace: ', inspect(trace))
end

return Trace
