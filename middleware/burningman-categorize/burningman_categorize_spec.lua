local spec  = require 'spec.spec'
local cjson = require 'cjson'

describe("burningman_categorize", function()

  it("Adds a bunch of stuff to the response", function()

    local backend_json = cjson.encode({
      {name='foo', category='prty'},
      {name='bar', category='prty'},
      {name='baz', category='perf'},
    })

    local burningman_categorize   = spec.middleware('burningman-categorize/burningman_categorize.lua')
    local request                 = spec.request({method = 'GET', uri = '/'})
    local next_middleware         = spec.next_middleware(function()
      assert.contains(request, { method = 'GET', uri = '/' })
      return {status = 200, body = backend_json}
    end)

    local response = burningman_categorize(request, next_middleware)

    assert.spy(next_middleware).was_called()

    assert.contains(response, {status = 200 })

    local info = cjson.decode(response.body)

    assert.same(info.parties,      {{name='foo', category='prty'}, {name='bar', category='prty'}})
    assert.same(info.performances, {{name='baz', category='perf'}})
    assert.same(info.fire,         {})

    assert.equal(info.datainfo.nb_parties, 2)
    assert.equal(info.datainfo.nb_performances, 1)
    assert.equal(info.datainfo.nb_fire, 0)
  end)
end)


