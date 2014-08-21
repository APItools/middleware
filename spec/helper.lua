package.path = package.path .. ";./spec/pipeline/?;./spec/pipeline/?.lua"

local Pipeline  = require 'pipeline'

local helper = {}

helper.new_pipeline = function(mw_name, mw_path)
  local f       = assert(io.open(mw_path, "rb"))
  local mw_code = f:read("*all")
  f:close()

  return {
    service_id = 1,
    middlewares = {
      { position = 1,
        name     = mw_name,
        code     = mw_code
      }
    }
  }
end

helper.run = function(pipeline, url)
  -- FIXME add these as params/options
  ngx.var.request_method  = 'GET'
  ngx.var.scheme          = 'http'
  ngx.var.host            = 'localhost'
  ngx.var.is_args         = ''

  ngx.var.request_uri = '/foo/bar'
  Pipeline.execute(pipeline, url)
end

return helper
