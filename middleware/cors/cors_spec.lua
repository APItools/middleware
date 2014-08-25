local helper  = require 'spec.helper'
local cors    = require 'cors.cors'


describe("CORS", function()
  describe("when the status is not 404", function()
    it("does nothing", function()
      local request  = { method = 'GET', uri_full = '/'}
      local response = { status = 200, body = 'ok' }

      local res, env = helper.run(cors, request, response)

      assert.same(res, response)
      assert.same({}, env.bucket.middleware.get_keys())
      assert.same({}, env.send.emails)
    end)
  end)

  describe("when the status is 404", function()
    it("sends an email and marks the middleware bucket", function()
      local request  = { method = 'GET', uri_full = '/'}
      local response = { status = 404, body = 'error' }

      local res, env = helper.run(cors, request, response)

      assert.same(res, response)
      assert.is_truthy(env.bucket.middleware.values.last_mail)
      assert.equal(#env.send.emails, 1)
      assert.same(env.send.emails[1], {to='YOUR-MAIL-HERE@gmail.com', subject="A 404 has ocurred", message="a 404 error happened in /"})
    end)

    it("does not send two emails when called twice in rapid succession", function()
      local request  = { method = 'GET', uri_full = '/'}
      local response = { status = 404, body = 'error' }

      local res, env = helper.run(cors, request, response)
      local res, env = helper.run(cors, request, response, env)

      assert.same(res, response)
      assert.equal(#env.send.emails, 1)
    end)

  end)
end)
