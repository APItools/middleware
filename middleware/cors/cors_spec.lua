local expect  = require 'spec.expect'
local cors    = require 'cors.cors'


describe("CORS", function()
  describe("when the status is not 404", function()
    it("does nothing", function()
      local request  = { method = 'GET', uri = '/'}
      local response = { status = 200, body = 'ok' }

      expect(cors):called_with(request, response)
        :to_pass(request)
        :to_return(response)
        :to_send_number_of_emails(0)
        :to_set_number_of_keys_in_middleware_bucket(0)
    end)
  end)

  describe("when the status is 404", function()
    it("sends an email and marks the middleware bucket", function()
      local request  = { method = 'GET', uri = '/'}
      local response = { status = 404, body = 'error' }

      expect(cors):called_with(request, response)
        :to_return(response)
        :to_set_in_middleware_bucket('last_mail')
        :to_send_email('YOUR-MAIL-HERE@gmail.com', 'A 404 has ocurred', 'a 404 error happened in http://localhost/')
    end)

    it("does not send two emails when called twice in rapid succession", function()
      local request  = { method = 'GET', uri = '/'}
      local response = { status = 404, body = 'error' }

      expect(cors)
        :called_with(request, response) -- not a typo, call the same request twice
        :called_with(request, response)
        :to_send_number_of_emails(1)
        :to_set_number_of_keys_in_middleware_bucket(1)
    end)

  end)
end)
