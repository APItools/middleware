return function (request, next_middleware)
    request.headers['Accept-Encoding'] = 'identity'
    return next_middleware()
end

