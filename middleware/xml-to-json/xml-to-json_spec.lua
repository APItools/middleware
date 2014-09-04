local spec = require 'spec.spec'
local cjson = require 'cjson'

describe("xml-to-json", function()
  it("transforms an xml response into json, sets the appropiate content-type header", function()
    local backend_xml = '<list><a foo="bar">hello</a><b foo="bar">bye</b></list>'

    local xml_to_json     = spec.middleware('xml-to-json/xml-to-json.lua')
    local request         = spec.request({ method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, {method='GET', uri = '/'})
      return {
        status = 200,
        body = backend_xml,
        headers = {['Content-type'] = 'application/xml'}
      }
    end)

    local response = xml_to_json(request, next_middleware)

    assert.spy(next_middleware).was_called()
    assert.contains(response, {status = 200, headers = {['Content-type'] = 'application/json'}})
    assert.same(cjson.decode(response.body), {
      attrs = {},
      children = { {
          attrs = {
            ["1"] = "foo",
            foo = "bar"
          },
          children = { "hello" },
          tag = "a"
        }, {
          attrs = {
            ["1"] = "foo",
            foo = "bar"
          },
          children = { "bye" },
          tag = "b"
        } },
      tag = "list"
    })
  end)
end)
