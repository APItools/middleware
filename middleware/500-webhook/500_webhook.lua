return function(request, next_middleware)
  local webhook_url = 'http://example.org/'

  local response = next_middleware()

  if response.status == 500 then
    -- send POST request to webhook
    http.simple{method = 'POST', url = webhook_url, body = {error = response.body}}

    -- register webhook request
    bucket.middleware.set('last_webhook_request', time.now())
  end

  return response
end
