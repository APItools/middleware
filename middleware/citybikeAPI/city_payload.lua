return function(request, next_middleware)

  local response = next_middleware()
  local stations = json.decode(response.body)
  local nearest = {}
  -- change 5 to the number of results you are interested in.
  -- #stations for all of the stations

  for i=1,5 do 
    local s ={}
    s.stationName = stations[i].stationName
    s.longitude = stations[i].longitude
    s.latitude = stations[i].latitude
    s.availableBikes = stations[i].availableBikes
    s.availableDocks = stations[i].availableDocks
    s.distance = stations[i].distance
    s.city = stations[i].city
    nearest[i] = s
  end
  
  console.log(nearest)
  
  response.body = json.encode(nearest)
  
  return next_middleware()
end
