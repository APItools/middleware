local helper  = require 'spec.helper'
local cors    = require 'cors'


describe("CORS", function()
  describe("when the status is not 404", function()
    it("does nothing", function()
      local request  = { method = 'GET', uri = '/'}
      local response = { status = 200, body = 'ok' }

      local res, env = helper.run(cors, request, response)

      assert.same(res, response)
    end)
  end)
end)
