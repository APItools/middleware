# Slow request GitHub issue middleware

Open a GitHub issue when a request takes too much time. If a slow request to the same URL occurs more than once the middleware updates the associated issue by reopening it.

Default *threshold* is set to 1 second, you can update it in `slow_request_github_issue.lua`.

## Usage

1. Change `GITHUB_ACCESS_TOKEN` in `slow_request_github_issue.lua` with your GitHub API access token.
1. Change `GITHUB_REPO_FULL_NAME` in `slow_request_github_issue.lua` with your GitHub repository full name, e.g. 'leafo/lapis'.
