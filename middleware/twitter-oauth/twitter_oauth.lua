return function (request, next_middleware)
  -- change to your own Twitter keys
  local api_key = "MY_TWITTER_API_KEY"
  local api_secret = "MY_TWITTER_API_SECRET"

  -- concatenate by ':'
  local str = api_key .. ':' .. api_secret
  console.log(str)

  -- generate base64 string
  local auth_header = "Basic ".. base64.encode(str)
  console.log(auth_header)

  -- headers to pass to /oauth2/ endpoint
  local headers_val ={}
  headers_val["Authorization"]=auth_header
  headers_val["Content-Type"]="application/x-www-form-urlencoded;charset=UTF-8"


  -- call to get access_token
  local body = http.simple{method='POST',url='https://api.twitter.com/oauth2/token',headers=headers_val, body={grant_type="client_credentials"}}
  local resp = json.decode(body)
  console.log("access_token",resp.access_token)


  -- pass the access_token to auth call
  request.headers.Authorization = "Bearer ".. resp.access_token

  return next_middleware()
end
