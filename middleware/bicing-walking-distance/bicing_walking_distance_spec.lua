local spec  = require 'spec.spec'
local cjson = require 'cjson'

describe("bicing_walking_distance", function()

  it("adds a walking distance route to all the stations on the given json, asking Google", function()

    local input_json = ([[
      [
        {"name":"barceloneta", "lat":41.382335, "long":2.185941},
        {"name":"sagrada-familia", "lat":41.403575, "long":2.174483}
      ]
    ]]):gsub('%s', '')

    local bicing_walking_distance = spec.middleware('bicing-walking-distance/bicing_walking_distance.lua')
    local request                 = spec.request({method = 'GET', uri = '/'})
    local next_middleware         = spec.next_middleware(function()
      assert.contains(request, { method = 'GET', uri = '/' })
      return {status = 200, body = input_json}
    end)

    local gapi_start = 'https://maps.googleapis.com//maps/api/distancematrix/json?mode=walking&sensor=false&origins=41.387678,2.169587'
    spec.mock_http({url = gapi_start .. '&destinations=41.382335,2.185941'},{body = '[1,2,3]'})
    spec.mock_http({url = gapi_start .. '&destinations=41.403575,2.174483'},{body = '[4,5,6]'})

    local response = bicing_walking_distance(request, next_middleware)

    assert.spy(next_middleware).was_called()

    assert.contains(response, {status = 200 })

    assert.same(cjson.decode(response.body), {
      {name="barceloneta",     lat=41.382335, long=2.185941, route = {1,2,3}},
      {name="sagrada-familia", lat=41.403575, long=2.174483, route = {4,5,6}}
    })
  end)

end)


