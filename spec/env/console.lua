local inspect = require 'spec.env.inspect'

local Console = {}

local function log(level, ...)
  local args = {...}
  if #args == 1 then args = args[1] end
  if type(args) ~= 'string' then args = inspect(args) end

  print(('Console %s: %s'):format(level, args))
end

function Console.new()

  return {
    log = function(...)
      log('Log', ...)
    end,
    debug = function(...)
      log('Debug', ...)
    end,
    info = function(...)
      log('Info', ...)
    end,
    warn = function(...)
      log('Warn', ...)
    end,
    error = function(...)
      log('Error', ...)
    end
  }
end

return Console
