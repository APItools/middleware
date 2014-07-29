return function (request, next_middleware)
  request.headers.authentication = 'this-is-my-key'
  return next_middleware()
end
