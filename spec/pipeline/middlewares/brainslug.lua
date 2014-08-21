return function(req, next_middleware)
  local res = ngx.location.capture(req.uri_full, {
    method  = ngx["HTTP_" .. req.method],
    args    = req.args,
    headers = req.headers
  })
  return res
end
