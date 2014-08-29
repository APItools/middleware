local spec  = require 'spec.spec'
local alert = require '404-alert.404_alert'

describe("404 alert", function()
  before_each(function()
    spec.reset()
  end)

  describe("when the status is not 404", function()
    it("does nothing", function()
      local request         = spec.request({method = 'GET', uri = '/'})
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        return {status = 200, body = 'ok'}
      end)

      local response = alert(request, next_middleware)
      assert.contains(response, {status = 200, body = 'ok'})

      assert.spy(next_middleare).was_called()
      assert.equal(#spec.sent.emails, 0)
      assert.equal(#spec.bucket.middleware, 0)
    end)
  end)

  describe("when the status is 404", function()
    it("sends an email and marks the middleware bucket", function()
      local request         = spec.request({uri = '/'})
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        return {status = 404, body = 'not ok'}
      end)

      local response = alert(request, next_middleware)
      assert.spy(next_middleare).was_called()
      assert.contains(response, {status = 404, body = 'not ok'})

      assert.thruthy(spec.bucket.middleware.last_mail)

      local last_email = spec.sent.emails.last
      assert.equal('YOUR-MAIL-HERE@gmail.com', last_email.to)
      assert.equal('A 404 has ocurred', last_email.subject)
      assert.equal('a 404 error happened in http://localhost/ see full trace: <trace_link>', last_email.body)
    end)

    it("does not send two emails when called twice in rapid succession", function()
      local request         = spec.request({method = 'GET', uri = '/'})
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        return {status = 200, body = 'ok'}
      end)

      alert(request, next_middleware)
      alert(request, next_middleware) -- twice
      assert.spy(next_middleare).was_called(2)

      assert.equal(1, #spec.sent.emails)
    end)

  end)
end)
