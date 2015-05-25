local indexOf = function( t, object )
  if "table" == type( t ) then
    for i = 1, #t do
        if object == t[i] then
            return i
        end
    end
    return -1
  else
    error("indexOf expects table for first argument, " .. type(t) .. " given")
  end
end

return function(request, next_middleware)
  local response = next_middleware()
  local data = json.decode(response.body).data

  -- CHANGE THIS TO THE CATEGORY YOU ARE INTERESTED IN
  local category='ecommerce'

  local r ={}
  for i=1,#data do
    if(indexOf(data[i].categories, category) ~= -1) then
     table.insert(r,data[i])
    end
  end

  response.body = json.encode({data=r})
  return response
end
