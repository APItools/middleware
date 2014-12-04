local bitbucket_username = 'BITBUCKET_USERNAME'
local bitbucket_password = 'BITBUCKET_PASSWORD'
local bitbucket_repo_full_name = 'BITBUCKET_REPO_FULL_NAME'

-- taken from leafo/lapis
-- see https://github.com/leafo/lapis/blob/v1.0.6/lapis/util.lua#L108-L110
local function slugify(str)
  return (str:gsub("[%s_]+", "-"):gsub("[^%w%-]+", ""):gsub("-+", "-")):lower()
end

-- makes an authenticated request to Bitbucket API
local function bitbucket_request(method, path, body)
  local auth = bitbucket_username .. ':' .. bitbucket_password
  local request = {
    method = method,
    url = 'https://bitbucket.org/api/1.0' .. path,
    headers = {Authorization = 'Basic ' .. base64.encode(auth)},
    body = body
  }
  local response_body = http.simple(request)
  return json.decode(response_body)
end

-- makes a request to Bitbucket API to create a new issue
local function create_bitbucket_issue(body)
  local path = '/repositories/' .. bitbucket_repo_full_name .. '/issues'
  return bitbucket_request('POST', path, body)
end

-- makes a request to Bitbucket API to update an issue
local function update_bitbucket_issue(issue_number, body)
  local path = '/repositories/' .. bitbucket_repo_full_name .. '/issues/' .. issue_number
  return bitbucket_request('PUT', path, body)
end

return function(request, next_middleware)
  local response = next_middleware()

  if response.status == 500 then
    -- notify error
    send.notification({msg = response.body, level = 'error'})

    -- response body is used as key in the middleware bucket
    local issue_key = slugify(response.body)
    local issue_number = bucket.middleware.get(issue_key)

    if issue_number == nil then
      -- create a new Bitbucket issue
      local issue = create_bitbucket_issue({title = request.uri, content = response.body})

      -- register issue number
      bucket.middleware.set(issue_key, issue.local_id)
    else
      -- update the Bitbucket issue (reopen)
      update_bitbucket_issue(issue_number, {status = 'open'})
    end
  end

  return response
end
