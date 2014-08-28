-- split function to split a string by a delimiter
local function split(s, delimiter)
  local result = {}
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match)
  end
  return result
end

return function(request, next_middleware)
  local apiToken = 'YO_API_TOKEN'
  request.headers['Content-Type'] = 'application/json'

  -- endpoint to send an individual yo is called
  if request.uri == '/yo/' then
    local body = request.body

    local yoUsername = split(body,'=')[2]
    console.log(yoUsername)

    request.body = '{"username":"'.. string.upper(yoUsername) .. '","api_token":"' .. apiToken .. '"}'

  -- endpoint to Yo all is called
  elseif request.uri =='/yoall/' then

    request.body = '{"api_token":"' .. apiToken .. '"}'

  -- callback url is called
  elseif request.uri == '/' then
    send.mail('me@email.com','New Yo subscriber', 'NEW Yo SUBSCRIBER ' .. request.args.username)
    send.notification({msg="new subscriber " .. request.args.username, level='info'})
  end

  console.log(request.body)

  return next_middleware()
end
