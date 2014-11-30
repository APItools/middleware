return function(request, next_middleware)
  
  local keen_write_token = "YOUR-WRITE-KEEN-IO-TOKEN-HERE"

  -- We want to modify the url by:
  --   #1 Adding the header X-GitHub-Event as name of the event
  --   #2 Add api_key
  local uri = request.uri
  
  -- if the url doesn't end with / add it
  if string.sub(uri,-string.len("/")) ~= "/" then
    uri = uri .. "/"
  end
  
  -- adding event to the url
  uri = uri .. "events/" .. request.headers["X-GitHub-Event"]
  
  -- adding the write token
  uri = uri .. '?api_key=' .. keen_write_token
  
  -- swap urls
  request.uri = uri
  
  local response = next_middleware()
  return response
end