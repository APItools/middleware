# 500 GitHub issue middleware

Open a Github issue when an error occurs. If an error occurs more than once the middleware updates the associated issue by reopening it.

## Usage

1. Change `GITHUB_ACCESS_TOKEN` in `500_github_issue.lua` with your GitHub API access token.
1. Change `GITHUB_REPO_FULL_NAME` in `500_github_issue.lua` with your GitHub repository full name, e.g. 'leafo/lapis'.
