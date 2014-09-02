local spec  = require 'spec.spec'

describe("bicing_json", function()

  it("transforms stations xml into json", function()
    local xml = ([[
      <stations>
        <station><name>peter</name><distance>2</distance></station>
        <station><name>jane</name><distance>3</distance></station>
        <station><name>ann</name><distance>10</distance></station>
      </stations>
    ]]):gsub('%s', '')

    local json = ([[
      [{"name":"peter","distance":"2"},{"name":"jane","distance":"3"},{"name":"ann","distance":"10"}]
    ]]):gsub('%s', '')


    local bicing_json     = spec.middleware('bicing-json/bicing_json.lua')
    local request         = spec.request({method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, { method = 'GET', uri = '/' })
      return {status = 200, body = xml}
    end)

    local response = bicing_json(request, next_middleware)

    assert.spy(next_middleware).was_called()
    assert.contains(response, {status = 200, body = json})
  end)

end)


