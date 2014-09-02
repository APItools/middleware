local spec        = require 'spec.spec'

describe("Accept encoding identity", function()
  it("adds a header", function()
    local accept          = spec.middleware('accept-encoding-identity/accept-encoding-identity.lua')
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
