return function(request, next_middleware)
  local uber_token = "YOUR_UBER_TOKEN"
  local start_latitude = "37.6189" -- SFO airport
  local start_longitude = "-122.3750"
  local start_name = "SFO Airport"
  local end_latitude = "37.7833" -- Powell station
  local end_longitude = "-122.4167"
  local end_name = "SF downtown"
  
  -- store in bucket, names of start and end points
  bucket.service.set("start_name",start_name)
  bucket.service.set("end_name",end_name)
 
  
  request.args.server_token = uber_token
  request.args.start_latitude = start_latitude
  request.args.start_longitude = start_longitude
  request.args.end_latitude = end_latitude
  request.args.end_longitude = end_longitude
  
  local response = next_middleware()
  return response
end