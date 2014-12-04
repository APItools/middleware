local spec = require 'spec.spec'

describe('500-github-issue', function()
  local issue
  before_each(function()
    issue = spec.middleware('500-github-issue/500_github_issue.lua')
  end)

  describe('when the status is not 500', function()
    it('does nothing', function()
      local request         = spec.request({method = 'GET', uri = '/'})
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        return {status = 200, body = 'ok'}
      end)

      local response = issue(request, next_middleware)

      assert.spy(next_middleware).was_called()
      assert.contains(response, {status = 200, body = 'ok'})

      assert.equal(#spec.sent.events, 0)
      assert.equal(#spec.bucket.middleware.get_keys(), 0)
    end)
  end)

  describe('when the status is 500', function()
    describe('when it happens once', function()
      it('sends a notification, sends a request to GitHub API, and marks the middleware bucket', function()
        local request         = spec.request({uri = '/'})
        local next_middleware = spec.next_middleware(function()
          assert.contains(request, {method = 'GET', uri = '/'})
          return {status = 500, body = 'an error message'}
        end)

        spec.mock_http({
          method   = 'POST',
          url      = 'https://api.github.com/repos/GITHUB_REPO_FULL_NAME/issues',
          body     = '{"title":"an error message"}',
          headers  = {Authorization = 'token GITHUB_ACCESS_TOKEN'}
        }, {
          body     = '{"url":"https://api.github.com/repos/owner/repo/issues/1","number":1}'
        })

        local response = issue(request, next_middleware)

        assert.spy(next_middleware).was_called()
        assert.contains(response, {status = 500, body = 'an error message'})

        assert.equal(1, #spec.sent.events)
        assert.truthy(spec.bucket.middleware.get('an-error-message'))

        local last_event = spec.sent.events.last
        assert.same({channel = 'middleware', level = 'error', msg = 'an error message'}, last_event)
      end)
    end)

    describe('when it happens more than once', function()
      it('sends two notifications and reopens GitHub issue', function()
        local request         = spec.request({method = 'GET', uri = '/'})
        local next_middleware = spec.next_middleware(function()
          assert.contains(request, {method = 'GET', uri = '/'})
          return {status = 500, body = 'an error message'}
        end)

        spec.mock_http({
          method   = 'POST',
          url      = 'https://api.github.com/repos/GITHUB_REPO_FULL_NAME/issues',
          body     = '{"title":"an error message"}',
          headers  = { Authorization = 'token GITHUB_ACCESS_TOKEN' }
        }, {
          body     = '{"url":"https://api.github.com/repos/owner/repo/issues/1","number":1}'
        })

        spec.mock_http({
          method   = 'POST', -- FIXME: this really should be PATCH, but http.simple is broken
          url      = 'https://api.github.com/repos/GITHUB_REPO_FULL_NAME/issues/1',
          body     = '{"state":"open"}',
          headers  = { Authorization = 'token GITHUB_ACCESS_TOKEN' }
        }, {
          body     = '{"url":"https://api.github.com/repos/owner/repo/issues/1","number":1}'
        })

        issue(request, next_middleware)
        issue(request, next_middleware) -- twice
        assert.spy(next_middleware).was_called(2)

        assert.equal(2, #spec.sent.events)
      end)
    end)

  end)
end)
