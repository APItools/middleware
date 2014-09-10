local spec = require 'spec.spec'

describe("yo-api", function()
  local yo
  before_each(function()
    yo = spec.middleware("yo-api/yo.lua")
  end)

  describe("when the uri is /", function()
    it("sends an email and a notification", function()
      local request         = spec.request({ method = 'GET', url = '/?username=peter' })
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {
          method = 'GET',
          uri = '/',
          query='username=peter',
          headers = {['Content-Type'] = 'application/json'}
        })
        return {status = 200, body = 'ok'}
      end)

      local response = yo(request, next_middleware)

      assert.spy(next_middleware).was_called()
      assert.contains(response, {status = 200, body = 'ok'})

      assert.equal(#spec.sent.emails, 1)

      local last_email = spec.sent.emails.last
      assert.equal('me@email.com', last_email.to)
      assert.equal('New Yo subscriber', last_email.subject)
      assert.equal('NEW Yo SUBSCRIBER peter', last_email.message)

      assert.equal(#spec.sent.events, 1)

      local last_event = spec.sent.events.last
      assert.same({channel='middleware', level='info', msg='new subscriber peter'}, last_event)
    end)
  end)

  describe("then the uri is /yoall/", function()
    it("passes the apitoken to the backend", function()

      local request         = spec.request({ method = 'GET', uri = '/yoall/'})
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {
          method   = 'GET',
          uri      = '/yoall/',
          headers  = {['Content-Type'] = 'application/json'},
          body     = '{"api_token":"YO_API_TOKEN"}'
        })
        return {status = 200, body = 'ok'}
      end)

      local response = yo(request, next_middleware)
      assert.spy(next_middleware).was_called()
      assert.contains(response, {status = 200, body = 'ok'})

      assert.equal(#spec.sent.emails, 0)
      assert.equal(#spec.sent.events, 0)
    end)
  end)

  describe("when the request is /yo/", function()
    it("passes & uppercases the username to the backend, plus the API token", function()
      local request         = spec.request({ method = 'GET', uri = '/yo/', body="username=peter"})
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {
          method   = 'GET',
          uri      = '/yo/',
          headers  = {['Content-Type']                                    = 'application/json'},
          body     = '{"username":"PETER","api_token":"YO_API_TOKEN"}'
        })
        return {status = 200, body = 'ok'}
      end)

      local response = yo(request, next_middleware)
      assert.spy(next_middleware).was_called()
      assert.contains(response, {status = 200, body = 'ok'})

      assert.equal(#spec.sent.emails, 0)
      assert.equal(#spec.sent.events, 0)
    end)
  end)
end)
