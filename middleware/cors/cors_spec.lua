local spec      = require 'spec.spec'
local raw_cors  = require 'cors.cors'

describe("CORS", function()
  it("adds a header", function()
    local cors            = spec.prepare(raw_cors)
    local request         = spec.request({ method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, { method = 'GET', uri = '/'})
      return {status = 200, body = 'ok'}
    end)

    local response = cors(request, next_middleware)

    assert.spy(next_middleware).was_called()
    assert.contains(response, {status = 200, body = 'ok', headers = {['Access-Control-Allow-Origin'] = "http://domain1.com http://domain2.com"}})
  end)
end)
