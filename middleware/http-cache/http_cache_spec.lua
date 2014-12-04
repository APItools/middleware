local spec = require 'spec.spec'

describe('HTTP Cache', function()
  local http_cache
  before_each(function()
    http_cache = spec.middleware('http-cache/http_cache.lua')
  end)

  it('it calls and returns next middleware', function()
    local request         = spec.request({method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, {method = 'GET', uri = '/'})
      return {status = 200, body = 'ok'}
    end)

    local response = http_cache(request, next_middleware)
    http_cache(request, next_middleware)

    assert.spy(next_middleware).was_called(2)

    assert.contains(response, {status = 200, body = 'ok'})
  end)

  it('stores response when it has all required headers', function()
    local request         = spec.request({method = 'GET', uri = '/path'})
    local next_middleware = spec.next_middleware(function()
      return {
	      status = 200,
	      body = 'ok',
	      headers = {
		      ['Etag'] = '"etag"',
  		      ['Last-Modified'] = "Sun, 30 Nov 2014 12:28:11 GMT",
		      ['Cache-Control'] = "public, max-age=60, s-maxage=60"
	      }
      }
    end)
    http_cache(request, next_middleware)
    assert.equal(#spec.bucket.middleware.get_keys(), 3)

    assert.spy(next_middleware).was_called()

    assert(spec.bucket.middleware.get('/path'))
    assert(spec.bucket.middleware.get('"etag"'))
    assert(spec.bucket.middleware.get('http://localhost/path'))
  end)

  it('stores caches the response', function()
    local request         = spec.request({method = 'GET', uri = '/path'})
    local next_middleware = spec.next_middleware(function()
      return {
	      status = 200,
	      body = 'ok',
	      headers = {
		      ['Etag'] = '"etag"',
  		      ['Last-Modified'] = "Sun, 30 Nov 2014 12:28:11 GMT",
		      ['Cache-Control'] = "public, max-age=60, s-maxage=60"
	      }
      }
    end)
    http_cache(request, next_middleware)
    http_cache(request, next_middleware)

    assert.spy(next_middleware).was_called(1)
  end)

end)
