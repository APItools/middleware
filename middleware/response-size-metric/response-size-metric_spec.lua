local spec = require 'spec.spec'

describe('response_size_metric', function()
  it('adds a metric with the size of the response body, in bytes', function()
    local response_size_metric = spec.middleware('response-size-metric/response-size-metric.lua')
    local request              = spec.request({method = 'GET', uri = '/'})
    local next_middleware      = spec.next_middleware(function()
      assert.contains(request, {method = 'GET', uri = '/'})
      return {status = 200, body = 'abcdef'}
    end)

    local response = response_size_metric(request, next_middleware)

    assert.spy(next_middleware).was_called()
    assert.contains(response, {status = 200, body = 'abcdef'})

    assert.equal(6, spec.metric.sets['size'])
  end)
end)
