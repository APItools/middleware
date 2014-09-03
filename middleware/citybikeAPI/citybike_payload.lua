return function(request, next_middleware)

  local response = next_middleware()
  local stations = json.decode(response.body)
  local nearest = {}
  -- change 5 to the number of results you are interested in.
  -- #stations for all of the stations

  for i=1,5 do
    nearest[i] = {
      stationName     = stations[i].stationName,
      longitude       = stations[i].longitude,
      latitude        = stations[i].latitude,
      availableBikes  = stations[i].availableBikes,
      availableDocks  = stations[i].availableDocks,
      distance        = stations[i].distance,
      city            = stations[i].city
    }
  end

  response.body = json.encode(nearest)

  return response
end
