return function (request, next_middleware)
  request.args.new_param = '1' -- adds new query param
  request.args.old_param = nil -- removes one if it was passed

  return next_middleware()
end
