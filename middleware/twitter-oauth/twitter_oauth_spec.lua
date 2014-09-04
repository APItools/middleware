local spec = require 'spec.spec'

describe("Twitter-oauth", function()
  it("uses the api key + secret to call twitter API and include an Authorization token in the request headers", function()
    local twitter_oauth   = spec.middleware('twitter-oauth/twitter_oauth.lua')
    local request         = spec.request({ method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, {
        method = 'GET',
        uri = '/',
        headers = { Authorization = 'Bearer foo'}
      })
      return {status = 200, body = 'ok'}
    end)

    spec.mock_http({
      method   = "POST",
      url      = 'https://api.twitter.com/oauth2/token',
      body     = 'grant%5Ftype=client%5Fcredentials',
      headers  = {
        Authorization       = "Basic TVlfVFdJVFRFUl9BUElfS0VZOk1ZX1RXSVRURVJfQVBJX1NFQ1JFVA==",
        ["Content-Type"]    = "application/x-www-form-urlencoded;charset=UTF-8",
        ["Content-type"]    = "application/x-www-form-urlencoded",
        ["content-length"]  = 33
      }
    }, {
      body     = '{"access_token":"foo"}'
    })

    local response = twitter_oauth(request, next_middleware)

    assert.spy(next_middleware).was_called()
    assert.contains(response, {status = 200, body = 'ok'})
  end)
end)
