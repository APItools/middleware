local spec  = require 'spec.spec'
local cjson = require 'cjson'

describe("citybike_distance", function()

  it("adds a distance attribute to all the elements in the received json array, using their lat and long. Also, sorts by distance", function()

    local input_json = cjson.encode({
      {stationName="Hipster Men Clothes", latitude=37.761353, longitude = -122.4298161, availableBikes=1, availableDocks=0, distance=1, city='sf', foo='bar'},
      {stationName="Fancy Coffee Shop", latitude=37.760288, longitude = -122.504993, availableBikes=1, availableDocks=0, distance=2, city='sf', foo='bar' },
      {stationName="Apple Store",  latitude=37.785991, longitude = -122.406470, availableBikes=1, availableDocks=0, distance=3, city='sf', foo='bar' },
      {stationName="Apple Store",  latitude=37.785991, longitude = -122.406470, availableBikes=1, availableDocks=0, distance=4, city='sf', foo='bar' },
      {stationName="Apple Store",  latitude=37.785991, longitude = -122.406470, availableBikes=1, availableDocks=0, distance=5, city='sf', foo='bar' },
      {stationName="Apple Store",  latitude=37.785991, longitude = -122.406470, availableBikes=1, availableDocks=0, distance=6, city='sf', foo='bar' },
    })

    local citibike_payload = spec.middleware('citybikeAPI/citybike_payload.lua')
    local request           = spec.request({method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, { method = 'GET', uri = '/' })
      return {status = 200, body = input_json}
    end)

    local response = citibike_payload(request, next_middleware)

    assert.spy(next_middleware).was_called()

    assert.contains(response, {status = 200 })

    assert.same(cjson.decode(response.body), {
      {stationName="Hipster Men Clothes", latitude=37.761353, longitude = -122.4298161, availableBikes=1, availableDocks=0, distance=1, city='sf'},
      {stationName="Fancy Coffee Shop", latitude=37.760288, longitude = -122.504993, availableBikes=1, availableDocks=0, distance=2, city='sf' },
      {stationName="Apple Store",  latitude=37.785991, longitude = -122.406470, availableBikes=1, availableDocks=0, distance=3, city='sf' },
      {stationName="Apple Store",  latitude=37.785991, longitude = -122.406470, availableBikes=1, availableDocks=0, distance=4, city='sf' },
      {stationName="Apple Store",  latitude=37.785991, longitude = -122.406470, availableBikes=1, availableDocks=0, distance=5, city='sf' }
    })
  end)
end)


