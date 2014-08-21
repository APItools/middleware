--[[
--
-- This middleware takes 10 stations and gets walking distance from Google Maps.
--
--]]

-- Pl. Catalunya
local lat = 41.3876780
local long = 2.16958700

local maps = 'https://maps.googleapis.com//maps/api/distancematrix/json'

return function(request, next_middleware)
  local response = next_middleware()

  local stations = json.decode(response.body)
  local nearest = {}
  for i=1,10 do
    nearest[i] = stations[i]
  end

  local requests = {}
  for i,station in ipairs(nearest) do
    requests[i] = {
      method = 'GET',
      url = maps .. "?origins="..lat..','..long.."&destinations="..station.lat ..","..station.long.."&mode=walking&sensor=false"
    }
  end

  local responses = http.multi(requests)

  for i,response in ipairs(responses) do
    nearest[i].route = json.decode(response.body)
  end

  response.body = json.encode(nearest)

  return response
end
