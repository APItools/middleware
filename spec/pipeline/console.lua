local Console = {}

local function log(level, service_id, uuid, ...)
  local args = {...}
  if #args == 1 then args = args[1] end
  if type(args) ~= 'string' then args = inspect(args) end

  print(('Console %d/%s %s: %s'):format(service_id, uuid, level, args))
end

function Console.new(service_id, uuid)

  return {
    log = function(...)
      log('Log', service_id, uuid, ...)
    end,
    debug = function(...)
      log('Debug', service_id, uuid, ...)
    end,
    info = function(...)
      log('Info', service_id, uuid, ...)
    end,
    warn = function(...)
      log('Warn', service_id, uuid, ...)
    end,
    error = function(...)
      log('Error', service_id, uuid, ...)
    end
  }
end

return Console
