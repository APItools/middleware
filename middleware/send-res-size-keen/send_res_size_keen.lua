return function (request, next_middleware)
  local response = next_middleware()
  local api_key = "YOUR-KEEN-IO-API-KEY-HERE"
  local size = base64.encode(json.encode({ size = #response.body }))
  http.get('https://api.keen.io/3.0/projects//<PROJECT_ID>/events/<EVENT_COLLECTION>?api_key=' .. api_key .. '&data=' .. size)
  return response
end
