local spec  = require 'spec.spec'
local cjson = require 'cjson'

describe("bicing_distance", function()

  it("adds a distance attribute to all the elements in the received json array, using their lat and long", function()

    local input_json = ([[
      [
        {"name":"barceloneta", "lat":41.382335, "long":2.185941},
        {"name":"sagrada-familia", "lat":41.403575, "long":2.174483}
      ]
    ]]):gsub('%s', '')

    local bicing_distance = spec.middleware('bicing-distance/bicing_distance.lua')
    local request         = spec.request({method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, { method = 'GET', uri = '/' })
      return {status = 200, body = input_json}
    end)

    local response = bicing_distance(request, next_middleware)

    assert.spy(next_middleware).was_called()

    assert.contains(response, {status = 200 })

    assert.same(cjson.decode(response.body), {
      {name="barceloneta",     lat=41.382335, long=2.185941, distance=0.92467453001388},
      {name="sagrada-familia", lat=41.403575, long=2.174483, distance=1.1273100485807}
    })

  end)

end)


