local spec = require 'spec.spec'

describe('privacy', function()
  it("does nothing (everything is commented out", function()
    local privacy = spec.middleware('privacy/privacy.lua')

    local request         = spec.request({method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, {method = 'GET', uri = '/'})
      return {status = 200, body = 'ok'}
    end)

    local response = privacy(request, next_middleware)

    assert.spy(next_middleware).was_called()
    assert.contains(response, {status = 200, body = 'ok'})
  end)
end)
