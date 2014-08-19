return function(request, next_middleware)

  local response = next_middleware()
  local events = json.decode(response.body)
  local newresponse ={}
  
  for i=1,#events do
    local e ={}
    local currentEvent = events[i];
    e.title = currentEvent.title
    e.desc = currentEvent.description
    e.id = currentEvent.id
    e.host = currentEvent.hosted_by_camp
    e.url =currentEvent.url
    e.location = currentEvent.other_location
    e.category = currentEvent.event_type.abbr
    
    console.log(tostring(#currentEvent.occurrence_set),tostring(currentEvent.title))
    for j=1,#currentEvent.occurrence_set do
      e.start_time = currentEvent.occurrence_set[j].start_time
      e.end_time = currentEvent.occurrence_set[j].end_time
      table.insert(newresponse,e)
    end
  end
  
  console.log("nb events ", tostring(#events));
  console.log("nb total ", tostring(#newresponse));
  
  response.body = json.encode(newresponse)
  
  return next_middleware()
end
