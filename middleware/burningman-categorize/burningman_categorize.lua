return function(request, next_middleware)
  -- every middleware has to call next_middleware,
  -- so others have chance to process the request/response

  local response = next_middleware()
  local events = json.decode(response.body)
  local parties = {} --prty
  local workshops ={} -- work
  local nocategory={} --none
  local ceremonies = {} --cere
  local cares ={} -- care
  local kids = {} -- kid
  local adults = {} --adlt
  local games ={} --game
  local parades ={} --para
  local fire={} --fire
  local food ={} --food
  local performances ={} --perf
  
  local dataInfo ={}
  
  for i=1,#events do
    local currentEvent = events[i]
    
    if(currentEvent.category=='cere') then
      table.insert(ceremonies,currentEvent)
    elseif (currentEvent.category=='prty') then
      table.insert(parties,currentEvent)
    elseif(currentEvent.category=='work') then
      table.insert(workshops,currentEvent)
    elseif(currentEvent.category=='none') then
      table.insert(nocategory,currentEvent)
    elseif(currentEvent.category=='care') then
      table.insert(cares,currentEvent)
    elseif(currentEvent.category=='kid') then
      table.insert(kids,currentEvent)
    elseif(currentEvent.category=='adlt') then
      table.insert(adults,currentEvent)
    elseif(currentEvent.category=='game') then
      table.insert(games,currentEvent)
    elseif(currentEvent.category=='para') then
      table.insert(parades,currentEvent)
    elseif(currentEvent.category=='fire') then
      table.insert(fire,currentEvent)
    elseif(currentEvent.category=='food') then
      table.insert(food,currentEvent)
    elseif(currentEvent.category=='perf') then
      table.insert(performances,currentEvent)
    end
  end
  
  dataInfo.nb_events = #events
  dataInfo.nb_parties = #parties
  dataInfo.nb_workshops = #workshops
  dataInfo.nb_ceremonies = #ceremonies
  dataInfo.nb_cares = #cares
  dataInfo.nb_adults = #adults
  dataInfo.nb_games = #games
  dataInfo.nb_food = #food
  dataInfo.nb_fire = #fire
  dataInfo.nb_performances = #performances
  dataInfo.nb_parades = #parades
  dataInfo.nb_kids = #kids
  dataInfo.nb_uncategorized = #nocategory
  
  local newresponse ={}
  newresponse.parties = parties
  newresponse.workshops = workshops
  newresponse.ceremonies = ceremonies
  newresponse.cares = cares
  newresponse.adults = adults
  newresponse.games = games
  newresponse.food = food
  newresponse.fire = fire
  newresponse.performances = performances
  newresponse.parades = parades
  newresponse.kids = kids
  newresponse.uncategorized = nocategory
  newresponse.datainfo = dataInfo
  
  response.body = json.encode(newresponse)
  
  return next_middleware()
end
