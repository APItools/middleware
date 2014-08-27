local expect  = require 'spec.expect'
local yo      = require 'yo-api.yo'


describe("yo-api", function()
  describe("when the uri is /", function()
    it("sends an email and a notification", function()
      local request            = { method = 'GET', url = '/?username=peter' }
      local request_to_backend = { method = 'GET', url = '/?username=peter', headers = {['Content-Type'] = 'application/json'}}

      expect(yo):called_with(request)
        :to_pass(request_to_backend)
        :to_send_number_of_emails(1)
        :to_send_email('me@email.com', 'New Yo subscriber', 'NEW Yo SUBSCRIBER peter')
        :to_send_number_of_events(1)
        :to_send_event({channel='middleware', level='info', msg='new subscriber peter'})
    end)
  end)

  describe("then the uri is /yoall/", function()
    it("returns the apitoken", function()

      local request            = { method = 'GET', uri = '/yoall/'}
      local request_to_backend = { method = 'GET',
                                   uri = '/yoall/',
                                   headers = {['Content-Type'] = 'application/json'},
                                   body    = '{"api_token":"YO_API_TOKEN"}' }

      expect(yo):called_with(request)
        :to_pass(request_to_backend)
    end)
  end)
end)
