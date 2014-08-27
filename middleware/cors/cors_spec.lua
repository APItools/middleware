local expect  = require 'spec.expect'
local cors    = require 'cors.cors'


describe("CORS", function()
  it("adds a header", function()
      local request           = { method = 'GET', uri = '/'}
      local backend_response  = { status = 200, body = 'ok' }
      local expected_response = { status = 200, body = 'ok', headers = {['Access-Control-Allow-Origin'] = "http://domain1.com http://domain2.com"}}

      expect(cors):called_with(request, backend_response)
        :to_pass(request)
        :to_receive(backend_response)
        :to_return(expected_response)
  end)
end)
