--[[
--
-- This middleware is using HTTP Semantics like Last-Modified and Etag to cache responses.
-- Works transparently with clients that do not use caching.
-- Naively implements Cache-Control private, no-cache and no-store (by not caching at all).
-- Adds Age header to cached responses that indicates how long since last recheck.
--]]

local function use_cache(request)
  local cache_control = request.cache_control
  if cache_control['no-cache'] or cache_control['private'] or cache_control['no-store'] then
    return false
  end
  return request.method == 'GET'
end

local function split_header(string)
  local split = {}
  if not string then return split end
  for k in string.gmatch(string, "([a-z-]+)") do
    split[#split] = k
    split[k] = true
  end
  for k, v in string.gmatch(string, "([%w-]+)=(%w+)") do
    split[k] = v
  end
  return split
end

local function fresh(cache, request)
  local max_age = request.cache_control['max-age']
  if max_age then
    return (time.now() - cache.stored) <= tonumber(max_age)
  else
    return true
  end
end

local function fetch(cached)
  local response = bucket.middleware.get(cached.etag)
  if response then
    response.headers['Age'] = math.ceil(time.now() - cached.stored)
    metric.count('cache.hit')
  end
  return response
end

local function fetch_cache(request)
  local cached = bucket.middleware.get(request.uri_relative)

  if cached and cached.etag then
    if fresh(cached, request) then
      return fetch(cached)
    end
  end
end

local function cache_response(request, response, cached)
  local cache_control = response.cache_control
  local max_age = tonumber(cache_control['max-age'] or cache_control['s-maxage']) or 0

  if not cache_control['public'] and max_age > 0 then return response end

  local last_modified = response.headers['Last-Modified']
  local etag = response.headers['Etag']

  local metadata = { last_modified = last_modified, etag = etag, max_age = max_age, stored = time.now() }

  if cached and cached.response and response.status == 304 then
    metric.count('cache.refresh')
    response = cached.response
    cached = metadata
    response.headers['Age'] = math.ceil(time.now() - cached.stored)
  elseif etag and response.status == 200 then
    bucket.middleware.set(request.uri_full, metadata)
    bucket.middleware.add(etag, response)
    metric.count('cache.stored')
  end

  bucket.middleware.set(request.uri_relative, metadata, max_age)

  return response
end

local function fetch_upstream(request, next_middleware)
  local cached = bucket.middleware.get(request.uri_full)

  if cached then
    cached.response = bucket.middleware.get(cached.etag)

    if cached.response then
      request.headers['If-None-Match'] = cached.etag
      request.headers['If-Modified-Since'] = cached.last_modified
    end
  end

  local response = next_middleware()
  response.cache_control = split_header(response.headers['Cache-Control'])

  return cache_response(request, response, cached)
end

return function (request, next_middleware)
  request.cache_control = split_header(request.headers['Cache-Control'])

  if use_cache(request) then
    return fetch_cache(request) or fetch_upstream(request, next_middleware)
  else
    metric.count('cache.miss')
    return next_middleware()
  end
end

