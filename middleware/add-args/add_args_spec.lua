local spec     = require 'spec.spec'
local raw_add  = require 'add-args.add_args'

describe("Add args", function()
  it("adds a header", function()
    local add             = spec.prepare(raw_add)
    local request         = spec.request({ method = 'GET', uri = '/?old_param=1&foo=2'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, {
        method = 'GET',
        uri = '/',
        args = {foo = '2', new_param = '1'}
      })
      return {status = 200, body = 'ok'}
    end)

    local response = add(request, next_middleware)

    assert.spy(next_middleware).was_called()
    assert.contains(response, {status = 200, body = 'ok'})
  end)
end)
