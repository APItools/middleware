# 500 Bitbucket issue middleware

Open a Bitbucket issue when an error occurs. If an error occurs more than once the middleware updates the associated issue by reopening it.

## Usage

1. Change `BITBUCKET_USERNAME` and `BITBUCKET_PASSWORD` in `500_bitbucket_issue.lua` with your Bitbucket username and password.
1. Change `BITBUCKET_REPO_FULL_NAME` in `500_bitbucket_issue.lua` with your Bitbucket repository full name, e.g. 'leafo/lapis'.
