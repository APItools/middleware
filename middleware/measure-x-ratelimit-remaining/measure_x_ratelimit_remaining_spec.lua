local spec = require 'spec.spec'

describe('measure_x_ratelimiting_remaining', function()
  local rate
  before_each(function()
    rate = spec.middleware('measure-x-ratelimit-remaining/measure_x_ratelimit_remaining.lua')
  end)

  describe('when a response does not have the required headers', function()
    it('does nothing', function()
      local request         = spec.request({method = 'GET', uri = '/'})
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        return {status = 200, body = 'ok'}
      end)

      local response = rate(request, next_middleware)

      assert.spy(next_middleware).was_called()
      assert.contains(response, {status = 200, body = 'ok'})

      assert.is_nil(spec.metric.sets['ratelimit-used'])
      assert.is_nil(spec.metric.sets['ratelimit-remaining'])
    end)
  end)

  describe('when a response has the required headers', function()
    it('emmits metrics', function()
      local request         = spec.request({method = 'GET', uri = '/'})
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        return {
          status = 200,
          body = 'ok',
          headers = {
            ['X-Ratelimit-Remaining'] = 1,
            ['X-Ratelimit-Limit']     = 5
          }
        }
      end)

      local response = rate(request, next_middleware)

      assert.spy(next_middleware).was_called()
      assert.contains(response, {status = 200, body = 'ok'})

      assert.equal(spec.metric.sets['ratelimit-used'], 4)
      assert.equal(spec.metric.sets['ratelimit-remaining'], 1)
    end)
  end)
end)
