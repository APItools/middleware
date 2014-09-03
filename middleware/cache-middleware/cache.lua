return function (request, next_middleware)
  -- initialize cache store

  local threshold = 60 -- 60 seconds
  local key = 'cache=' .. request.uri_full

  if request.method == "GET" then
    local stored = bucket.middleware.get(key)
    if stored then
      local expires = stored.headers['X-Expires']

      if expires and expires > time.now() then -- not expired yet
        -- send.event({channel = "cache", msg = "returned cached content", level = "debug", key = key, content = stored, expires = expires, now = time.now() })
        stored.headers['Expires'] = time.http(expires)

        return stored
      else
        bucket.middleware.delete(key)
        -- send.event({channel = "cache", msg = "NOT  cached content", level = "debug", key = key, content = stored, expires = expires, now = time.now() })
      end
    end
  end

  -- if content is not cached, do the real request & get response
  local response = next_middleware()

  if request.method == 'GET' then
    local expires = time.now() + threshold
    response.headers['X-Expires'] = expires
    bucket.middleware.set(key, response, expires)
    -- send.event({channel = "cache", msg = "stored cached content", level = "debug", content = response })
  end

  return response
end
