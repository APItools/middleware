return function (request, next_middleware)
  local res = next_middleware()
  request.headers.authentication = '**filtered**'
  return res
end
