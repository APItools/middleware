local spec  = require 'spec.spec'
local cjson = require 'cjson'

describe("bicing_distance", function()

  it("adds a distance attribute to all the elements in the received json array, using their lat and long", function()

    local input_json = cjson.encode({
      {name="barceloneta",     lat=41.382335, long=2.185941},
      {name="sagrada-familia", lat=41.403575, long=2.174483}
    })

    local bicing_distance = spec.middleware('bicing-distance/bicing_distance.lua')
    local request         = spec.request({method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, { method = 'GET', uri = '/' })
      return {status = 200, body = input_json}
    end)

    local response = bicing_distance(request, next_middleware)

    assert.spy(next_middleware).was_called()

    assert.contains(response, {status = 200 })

    local response_info = cjson.decode(response.body)
    assert.contains(response_info, {
      {name="barceloneta",     lat=41.382335, long=2.185941},
      {name="sagrada-familia", lat=41.403575, long=2.174483}
    })

    -- Floating point comparisons can vary depending on the LuaJIT version;
    -- compare them using a threshold
    assert.difference(response_info[1].distance, 0.92467453001395)
    assert.difference(response_info[2].distance, 1.1273100485806)
  end)

end)


