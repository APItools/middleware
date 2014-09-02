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

  local datainfo ={}
  datainfo.nb_events = #events
  datainfo.nb_parties = #parties
  datainfo.nb_workshops = #workshops
  datainfo.nb_ceremonies = #ceremonies
  datainfo.nb_cares = #cares
  datainfo.nb_adults = #adults
  datainfo.nb_games = #games
  datainfo.nb_food = #food
  datainfo.nb_fire = #fire
  datainfo.nb_performances = #performances
  datainfo.nb_parades = #parades
  datainfo.nb_kids = #kids
  datainfo.nb_uncategorized = #nocategory

  local info = {}
  info.parties = parties
  info.workshops = workshops
  info.ceremonies = ceremonies
  info.cares = cares
  info.adults = adults
  info.games = games
  info.food = food
  info.fire = fire
  info.performances = performances
  info.parades = parades
  info.kids = kids
  info.uncategorized = nocategory
  info.datainfo = datainfo

  response.body = json.encode(info)

  return response
end
