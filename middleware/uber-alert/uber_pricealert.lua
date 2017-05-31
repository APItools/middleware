return function(request, next_middleware)
  local max_price = 600 -- Maximum price to trigger alert
  local my_address = "YOUR_EMAIL_ADDRESS"
  
  local response = next_middleware()
  
  local result = json.decode(response.body)
  local prices = result.prices
  
  local message= ""
  local nb_results = 0
  
  for _,price in ipairs(prices) do
    
    if(max_price > tonumber(price.low_estimate)) then
      
      if (nb_results ==0) then --first result
        message = "You can go from " ..bucket.service.get("start_name").. " to "..bucket.service.get("end_name").. " for less than "..max_price..price.currency_code.. " on ".. price.display_name
      end 
     
      nb_results = nb_results +1
      if(nb_results >1) then
         message= message .. " OR for less than "..max_price..price.currency_code.. " on ".. price.display_name
      end
    end 
  end
  
  
 if (nb_results > 0) then
    send.mail(my_address,"Price alert on Uber",message)
 end

  return next_middleware()
end