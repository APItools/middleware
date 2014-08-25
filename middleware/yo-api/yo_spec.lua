local helper  = require 'spec.helper'
local yo      = require 'yo-api.yo'


describe("yo-api", function()
  describe("when the uri is /", function()
    it("sends an email and a notification", function()
      local request  = { method = 'GET', uri = '/', args = {username = 'peter'}, headers = {}}
      local response = { status = 200, body = '' }

      local res, env = helper.run(yo, request, response)

      assert.same(res, response)
      assert.equal(#env.send.emails, 1)
      assert.same(env.send.emails[1], {to='me@email.com', subject="New Yo subscriber", message="NEW Yo SUBSCRIBER peter"})
      assert.equal(#env.send.events, 1)
      assert.same(env.send.events[1], {channel='middleware', level='info', msg='new subscriber peter'})
    end)
  end)
end)
