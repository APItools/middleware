local spec = require 'spec.spec'

describe('Slow request GitHub issue', function()
  local slow_request_github_issue
  before_each(function()
    slow_request_github_issue = spec.middleware('slow-request-github-issue/slow_request_github_issue.lua')
  end)

  describe('when the response is given quickly', function()
    it('does nothing', function()
      local request         = spec.request({method = 'GET', uri = '/'})
      local next_middleware = spec.next_middleware(function()
        assert.contains(request, {method = 'GET', uri = '/'})
        spec.advance_time(0.2) -- less than threshold (1 second)
        return {status = 200, body = 'ok'}
      end)

      local response = slow_request_github_issue(request, next_middleware)

      assert.spy(next_middleware).was_called()
      assert.contains(response, {status = 200, body = 'ok'})

      assert.equal(0, #spec.bucket.middleware:get_keys())
    end)
  end)

  describe('when the response takes more than the threshold', function()
    describe('when it happens once', function()
      it('creates a GitHub issue and marks the middleware bucket', function()
        local request         = spec.request({method = 'GET', uri = '/'})
        local next_middleware = spec.next_middleware(function()
          assert.contains(request, {method = 'GET', uri = '/'})
          spec.advance_time(2) -- 2 seconds
          return {status = 200, body = 'ok'}
        end)

        spec.mock_http({
          method   = 'POST',
          url      = 'https://api.github.com/repos/GITHUB_REPO_FULL_NAME/issues',
          body     = 'title=Slow+request+%282+seconds%29%3A+http%3A%2F%2Flocalhost%2F',
          headers  = {Authorization = 'token GITHUB_ACCESS_TOKEN'}
        }, {
          body     = '{"url":"https://api.github.com/repos/owner/repo/issues/1","number":1}'
        })

        local response = slow_request_github_issue(request, next_middleware)

        assert.spy(next_middleware).was_called()
        assert.contains(response, {status = 200, body = 'ok'})

        assert.truthy(spec.bucket.middleware.get('http://localhost/'))
      end)
    end)

    describe('when it happens more than once', function()
      it('reopens GitHub issue', function()
        local request         = spec.request({method = 'GET', uri = '/'})
        local next_middleware = spec.next_middleware(function()
          assert.contains(request, {method = 'GET', uri = '/'})
          spec.advance_time(2) -- 2 seconds
          return {status = 200, body = 'ok'}
        end)

        spec.mock_http({
          method   = 'POST',
          url      = 'https://api.github.com/repos/GITHUB_REPO_FULL_NAME/issues',
          body     = 'title=Slow+request+%282+seconds%29%3A+http%3A%2F%2Flocalhost%2F',
          headers  = {Authorization = 'token GITHUB_ACCESS_TOKEN'}
        }, {
          body     = '{"url":"https://api.github.com/repos/owner/repo/issues/1","number":1}'
        })

        spec.mock_http({
          method   = 'PATCH',
          url      = 'https://api.github.com/repos/GITHUB_REPO_FULL_NAME/issues/1',
          body     = 'state=open',
          headers  = {Authorization = 'token GITHUB_ACCESS_TOKEN'}
        }, {
          body     = '{"url":"https://api.github.com/repos/owner/repo/issues/1","number":1}'
        })

        slow_request_github_issue(request, next_middleware)
        spec.advance_time(2) -- 2 seconds
        slow_request_github_issue(request, next_middleware) -- twice

        assert.spy(next_middleware).was_called(2)
      end)
    end)

  end)
end)
