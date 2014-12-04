local github_access_token = 'GITHUB_ACCESS_TOKEN'
local github_repo_full_name = 'GITHUB_REPO_FULL_NAME'

-- taken from leafo/lapis
-- see https://github.com/leafo/lapis/blob/v1.0.6/lapis/util.lua#L108-L110
local function slugify(str)
  return (str:gsub("[%s_]+", "-"):gsub("[^%w%-]+", ""):gsub("-+", "-")):lower()
end

-- makes an authenticated request to GitHub API
local function github_request(method, path, body)
  local request = {
    method = method,
    url = 'https://api.github.com' .. path,
    headers = {Authorization = 'token ' .. github_access_token}
  }
  local response_body = http.simple(request, json.encode(body))
  return json.decode(response_body)
end

-- makes a request to GitHub API to create a new issue
local function create_github_issue(body)
  local path = '/repos/' .. github_repo_full_name .. '/issues'
  return github_request('POST', path, body)
end

-- makes a request to GitHub API to update an issue
local function update_github_issue(issue_number, body)
  local path = '/repos/' .. github_repo_full_name .. '/issues/' .. issue_number
  return github_request('PATCH', path, body)
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
      -- create a new GitHub issue
      local issue = create_github_issue({title = response.body})

      -- register issue number
      bucket.middleware.set(issue_key, issue.number)
    else
      -- update the GitHub issue (reopen)
      update_github_issue(issue_number, {state = 'open'})
    end
  end

  return response
end
