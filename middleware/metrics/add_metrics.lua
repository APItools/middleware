return function (request, next_middleware)
  local response = next_middleware()

  local remaining = response.headers['X-Ratelimit-Remaining']
  local limit = response.headers['X-Ratelimit-Limit']

  if limit and remaining then
    remaining = tonumber(remaining)
    limit = tonumber(limit)
    metric.set('ratelimit-used', limit - remaining)
    metric.set('ratelimit-remaining', remaining)
  end

  return response
end
