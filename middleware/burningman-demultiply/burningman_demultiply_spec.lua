local spec  = require 'spec.spec'
local cjson = require 'cjson'

describe("burningman_demultiply", function()

  it("Planarizes the events using start_time and end_time", function()

    local backend_json = cjson.encode({
      {
        title='event1',description='desc1',id=1,hosted_by_camp='peter',url='url1',other_location='loc1',
        event_type = { abbr ='prty' },
        occurrence_set = {
          {start_time = 1, end_time = 2},
          {start_time = 2, end_time = 3},
          {start_time = 3, end_time = 4},
        }
      },{
        title='event2',description='desc2',id=2,hosted_by_camp='john',url='url2',other_location='loc2',
        event_type = { abbr ='fire' },
        occurrence_set = {
          {start_time = 10, end_time = 50},
        }
      }
    })

    local burningman_demultiply   = spec.middleware('burningman-demultiply/burningman_demultiply.lua')
    local request                 = spec.request({method = 'GET', uri = '/'})
    local next_middleware         = spec.next_middleware(function()
      assert.contains(request, { method = 'GET', uri = '/' })
      return {status = 200, body = backend_json}
    end)

    local response = burningman_demultiply(request, next_middleware)

    assert.spy(next_middleware).was_called()

    assert.contains(response, {status = 200})

    local info = cjson.decode(response.body)

    assert.same(info, {
      { title='event1',desc='desc1',id=1,host='peter',url='url1',location='loc1',category='prty', start_time = 1, end_time = 2},
      { title='event1',desc='desc1',id=1,host='peter',url='url1',location='loc1',category='prty', start_time = 2, end_time = 3},
      { title='event1',desc='desc1',id=1,host='peter',url='url1',location='loc1',category='prty', start_time = 3, end_time = 4},
      { title='event2',desc='desc2',id=2,host='john',url='url2',location='loc2',category='fire', start_time = 10, end_time = 50}
    })
  end)

end)


