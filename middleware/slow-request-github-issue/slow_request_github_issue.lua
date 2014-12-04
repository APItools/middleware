return function(request, next_middleware)
  local threshold = 1.0 -- 1 second, for less use decimal numbers
  local github_access_token = 'GITHUB_ACCESS_TOKEN'
  local github_repo_full_name = 'GITHUB_REPO_FULL_NAME'

  local response = next_middleware()

  if trace.time > threshold then
    -- request.uri_full is used as key in the middleware bucket
    local issue_number = bucket.middleware.get(request.uri_full)

    local request_url = 'https://api.github.com/repos/' .. github_repo_full_name .. '/issues'
    local request_headers = {Authorization = 'token ' .. github_access_token}

    if issue_number == nil then
      -- create a new GitHub issue
      local request_body = {title = 'Slow request (' .. trace.time .. ' seconds): ' .. request.uri_full}
      local issue_response_body = http.simple({method = 'POST', url = request_url, headers = request_headers}, json.encode(request_body))
      local issue = json.decode(issue_response_body)

      -- register issue number
      bucket.middleware.set(request.uri_full, issue.number)
    else
      -- update the GitHub issue (reopen)
      request_url = request_url .. '/' .. issue_number
      local request_body = {state = 'open'}
      http.simple({method = 'PATCH', url = request_url, headers = request_headers}, json.encode(request_body))
    end
  end

  return response
end
