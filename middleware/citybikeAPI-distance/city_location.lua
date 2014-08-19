-- Center of San Francisco
local lat = 37.7873589
local long = -122.408227

local geo = { radius = 3958.75587 }

function geo.distance(lat1, lng1, lat2, lng2)
  local rlat = lat1*math.pi/180;
  local rlng = lng1*math.pi/180;
  local rlat2 = lat2*math.pi/180;
  local rlng2 = lng2*math.pi/180;
 
  if (rlat == rlat2 and rlng == rlng2) then
    return 0
  else
    -- Spherical Law of Cosines
    return geo.radius*math.acos(math.sin(rlat)*math.sin(rlat2)
      +math.cos(rlng-rlng2)*math.cos(rlat)*math.cos(rlat2))
  end
end

return function(request, next_middleware)
  local response = next_middleware()

  local stations = json.decode(response.body).stationBeanList
  console.log("STATIONS")
  console.log(stations)
  
  for _,station in ipairs(stations) do
    station.distance = geo.distance(station.latitude, station.longitude, lat, long)
  end
  
  table.sort(stations, function(one,two) return one.distance < two.distance end)
  
  response.body = json.encode(stations)
  
  return response
end