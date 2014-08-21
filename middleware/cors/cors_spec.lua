local fakengx = require 'spec.fakengx'
local helper  = require 'spec.helper'

local pipeline = helper.new_pipeline('cors', 'middleware/cors/cors.lua')

describe("CORS", function()

  before_each(function()
    _G.ngx = fakengx.new()
  end)

  describe("when the status is not 404", function()
    it("does nothing", function()
      ngx.location.stub('http://localhost/foo/bar', {}, {body = 'ok'})

      helper.run(pipeline, 'http://google.com')
      assert.is_true(true)
    end)
  end)
end)
