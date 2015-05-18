return function(request, next_middleware)
  local response = next_middleware()

  local data = json.decode(response.body).data

  local max_price = MAXIMUM_PRICE
  local min_price = MINIMUM_PRICE
  local r={}
  for i=1,#data do
    if(tonumber(data[i].face_value)>= min_price and tonumber(data[i].face_value) <= max_price) then
      table.insert(r,data[i])
    end
  end

  response.body = json.encode({data=r})

  return response
end
