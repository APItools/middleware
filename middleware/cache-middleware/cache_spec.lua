local spec  = require 'spec.spec'

describe("404 alert", function()
  local cache
  before_each(function()
    cache = spec.middleware('cache-middleware/cache.lua')
  end)

  describe("when the method is not GET", function()
    it("does nothing", function()
      local request         = spec.request({method = 'POST', uri = '/'})
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {method = 'POST', uri = '/'})
        return {status = 200, body = 'ok'}
      end)

      local response = cache(request, next_middleware)

      assert.spy(next_middleware).was_called()

      assert.contains(response, {status = 200, body = 'ok'})

      assert.equal(#spec.bucket.middleware.get_keys(), 0)
    end)
  end)

  describe("when the method is GET", function()
    it("the first time, it just calls the next middleware, but sets some stuff on the middleware bucket", function()
      local request         = spec.request({uri = '/'})
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        return {status = 200, body = 'ok'}
      end)

      local response = cache(request, next_middleware)

      assert.spy(next_middleware).was_called()

      assert.contains(response, {status = 200, body = 'ok', headers={}})
      assert.equal(type(response.headers['X-Expires']), 'number')

      assert.equal(#spec.bucket.middleware.get_keys(), 1)
      local stored = spec.bucket.middleware.get('cache=http://localhost/')

      assert.contains(stored, {status = 200, body = 'ok', headers = {}})
      assert.equal(type(stored.headers['X-Expires']), 'number')
    end)

    describe("when called twice", function()
      it("returns the cached result calling next_middleware only once", function()
        local request         = spec.request({uri = '/'})
        local next_middleware = spec.next_middleware(function()
          assert.contains(request, {method = 'GET', uri = '/'})
          return {status = 200, body = 'ok'}
        end)

        local response1 = cache(request, next_middleware)
        local response2 = cache(request, next_middleware)

        assert.spy(next_middleware).was_called(1)

        assert.contains(response1, {status = 200, body = 'ok', headers={}})
        assert.equal(type(response1.headers['X-Expires']), 'number')

        assert.contains(response2, {status = 200, body = 'ok', headers={}})
        assert.equal(type(response1.headers['X-Expires']), 'number')

        assert.equal(#spec.bucket.middleware.get_keys(), 1)
        local stored = spec.bucket.middleware.get('cache=http://localhost/')

        assert.contains(stored, {status = 200, body = 'ok', headers = {}})
        assert.equal(type(stored.headers['X-Expires']), 'number')
      end)

      it("forgets the cached result after a while, calling next_middleware twice", function()
        local request         = spec.request({uri = '/'})
        local next_middleware = spec.next_middleware(function()
          assert.contains(request, {method = 'GET', uri = '/'})
          return {status = 200, body = 'ok'}
        end)

        local response1 = cache(request, next_middleware)

        spec.advance_time(61)

        local response2 = cache(request, next_middleware)

        assert.spy(next_middleware).was_called(2)

        assert.contains(response1, {status = 200, body = 'ok', headers={}})
        assert.equal(type(response1.headers['X-Expires']), 'number')

        assert.contains(response2, {status = 200, body = 'ok', headers={}})
        assert.equal(type(response1.headers['X-Expires']), 'number')

        assert.equal(#spec.bucket.middleware.get_keys(), 1)
        local stored = spec.bucket.middleware.get('cache=http://localhost/')

        assert.contains(stored, {status = 200, body = 'ok', headers = {}})
        assert.equal(type(stored.headers['X-Expires']), 'number')
      end)
    end)
  end)
end)
