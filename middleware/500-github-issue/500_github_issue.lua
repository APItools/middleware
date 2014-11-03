return function(request, next_middleware)
  local github_access_token = 'GITHUB_ACCESS_TOKEN'
  local github_owner = 'GITHUB_OWNER'
  local github_repo = 'GITHUB_REPO'

  local response = next_middleware()

  if response.status == 500 then
    -- notify error
    send.notification({msg = response.body, level = 'error'})

    -- response body is used as key in the middleware bucket
    local issue_key = response.body:gsub(' ', '-')
    local issue_number = bucket.middleware.get(issue_key)

    local request_url = 'https://api.github.com/repos/' .. github_owner .. '/' .. github_repo .. '/issues'
    local request_headers = {Authorization = 'token ' .. github_access_token}

    if issue_number == nil then
      -- create a new GitHub issue
      local request_body = {title = response.body}
      local issue_response_body = http.simple{method = 'POST', url = request_url, headers = request_headers, body = request_body}
      local issue = json.decode(issue_response_body)

      -- register issue number
      bucket.middleware.set(issue_key, issue.number)
    else
      -- update the GitHub issue (reopen)
      request_url = request_url .. '/' .. issue_number
      local request_body = {state = 'open'}
      http.simple{method = 'PATCH', url = request_url, headers = request_headers, body = request_body}
    end
  end

  return response
end
