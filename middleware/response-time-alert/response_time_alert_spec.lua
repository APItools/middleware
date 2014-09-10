local spec = require 'spec.spec'

describe('response_time_alert', function()
  local response_time_alert
  before_each(function()
    response_time_alert = spec.middleware('response-time-alert/response_time_alert.lua')
  end)

  describe("when the response is given quickly", function()
    it("does nothing", function()
      local request              = spec.request({method = 'GET', uri = '/'})
      local next_middleware      = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        spec.advance_time(0.2) -- less than 1 second
        return {status = 200, body = 'ok'}
      end)

      local response = response_time_alert(request, next_middleware)

      assert.spy(next_middleware).was_called()
      assert.contains(response, {status = 200, body = 'ok'})
      assert.equal(#spec.sent.emails, 0)
      assert.equal(#spec.bucket.middleware:get_keys(), 0)
    end)
  end)

  describe("when the response takes more than the threshold", function()
    it("sends an email the first time this happens", function()
      local request              = spec.request({method = 'GET', uri = '/'})
      local next_middleware      = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        spec.advance_time(2) -- 2 seconds
        return {status = 200, body = 'ok'}
      end)

      local response = response_time_alert(request, next_middleware)

      assert.spy(next_middleware).was_called()
      assert.contains(response, {status = 200, body = 'ok'})
      assert.equal(#spec.sent.emails, 1)

      local last_email = spec.sent.emails.last
      assert.equal('YOUR-MAIL-HERE@gmail.com', last_email.to)
      assert.equal('Trace took more than 1', last_email.subject)
      assert.equal('http://localhost/ took more than 1 to load. See full trace:<trace_link>', last_email.message)

      assert.equal(type(spec.bucket.middleware.get('last_mail')), 'number' )
    end)

    it("does not send two emails if two slow responses happen quickly after one another", function()
      local request              = spec.request({method = 'GET', uri = '/'})
      local next_middleware      = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        spec.advance_time(2) -- 2 seconds
        return {status = 200, body = 'ok'}
      end)

      local response1 = response_time_alert(request, next_middleware)
      spec.advance_time(2) -- 2 seconds
      local response2 = response_time_alert(request, next_middleware)

      assert.spy(next_middleware).was_called(2)
      assert.contains(response1, {status = 200, body = 'ok'})
      assert.contains(response2, {status = 200, body = 'ok'})
      assert.equal(#spec.sent.emails, 1)

      local last_email = spec.sent.emails.last
      assert.equal('YOUR-MAIL-HERE@gmail.com', last_email.to)
      assert.equal('Trace took more than 1', last_email.subject)
      assert.equal('http://localhost/ took more than 1 to load. See full trace:<trace_link>', last_email.message)

      assert.equal(type(spec.bucket.middleware.get('last_mail')), 'number' )
    end)

    it("sends two emails if two slow responses happen with enough time separation between them", function()
      local request              = spec.request({method = 'GET', uri = '/'})
      local next_middleware      = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        spec.advance_time(2) -- 2 seconds
        return {status = 200, body = 'ok'}
      end)

      local response1 = response_time_alert(request, next_middleware)
      spec.advance_time(60*5 + 1) -- 5 minutes + 1 second
      local response2 = response_time_alert(request, next_middleware)

      assert.spy(next_middleware).was_called(2)
      assert.contains(response1, {status = 200, body = 'ok'})
      assert.contains(response2, {status = 200, body = 'ok'})

      assert.equal(#spec.sent.emails, 2)
    end)
  end)

end)
