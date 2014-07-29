return function (request, next_middleware)
    local response = next_middleware()
    response.headers["Access-Control-Allow-Origin"] = "*"
    return response
end
