local inspect = require 'inspect'

local Event = {}

function Event:create(tbl)
  print('Created event: ' .. inspect(tbl))
end

return Event
