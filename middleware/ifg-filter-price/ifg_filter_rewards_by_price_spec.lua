local spec = require 'spec.spec'
local cjson = require 'cjson'

describe("I feel good filter price", function()
  it("filters a price between min and maximum", function()
    local add             = spec.middleware('ifg-filter-price/ifg_filter_rewards_by_price.lua')
    local request         = spec.request({ method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, {
        method = 'GET',
        uri = '/',
      })
      return {status = 200, body = '{"data": [{"face_value": 1}, {"face_value": 5}, {"face_value": 10}]}' }
    end)

    local response = add(request, next_middleware)

    assert.spy(next_middleware).was_called()
    assert.equal(response.status, 200)
    assert.same(cjson.decode(response.body), {data={{face_value=5}}})
  end)
end)
