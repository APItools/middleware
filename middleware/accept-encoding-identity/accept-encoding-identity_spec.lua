local spec        = require 'spec.spec'
local raw_accept  = require 'accept-encoding-identity.accept-encoding-identity'

describe("Accept encoding identity", function()
  it("adds a header", function()
    local accept          = spec.prepare(raw_accept)
    local request         = spec.request({ method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, {method = 'GET', uri = '/', headers = {['Accept-Encoding'] = 'identity'}})
      return {status = 200, body = 'ok'}
    end)

    local response = accept(request, next_middleware)

    assert.spy(next_middleware).was_called()
    assert.contains(response, {status = 200, body = 'ok'})
  end)
end)
