local spec = require 'spec.spec'

describe('500 Webhook', function()
  local webhook
  before_each(function()
    webhook = spec.middleware('500-webhook/500_webhook.lua')
  end)

  describe('when the status is not 500', function()
    it('does nothing', function()
      local request         = spec.request({method = 'GET', uri = '/'})
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        return {status = 200, body = 'ok'}
      end)

      local response = webhook(request, next_middleware)

      assert.spy(next_middleware).was_called()
      assert.contains(response, {status = 200, body = 'ok'})

      assert.equal(0, #spec.bucket.middleware.get_keys())
    end)
  end)

  describe('when the status is 500', function()
    it('sends a request to webhook and marks the middleware bucket', function()
      local request         = spec.request({method = 'GET', uri = '/'})
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        return {status = 500, body = 'an error message'}
      end)

      spec.mock_http({
        method   = 'POST',
        url      = 'http://example.org/',
        body     = 'error=an+error+message'
      }, {})

      local response = webhook(request, next_middleware)

      assert.spy(next_middleware).was_called()
      assert.contains(response, {status = 500, body = 'an error message'})

      assert.truthy(spec.bucket.middleware.get('last_webhook_request'))
    end)
  end)

end)
