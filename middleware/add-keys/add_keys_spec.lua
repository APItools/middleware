local spec = require 'spec.spec'

describe("Add keys", function()
  it("adds a header", function()
    local add             = spec.middleware('add-keys/add_keys.lua')
    local request         = spec.request({ method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, {
        method = 'GET',
        uri = '/',
        headers = { authentication = 'this-is-my-key'}
      })
      return {status = 200, body = 'ok'}
    end)

    local response = add(request, next_middleware)

    assert.spy(next_middleware).was_called()
    assert.contains(response, {status = 200, body = 'ok'})
  end)
end)
