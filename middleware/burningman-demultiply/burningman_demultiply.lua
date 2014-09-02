return function(request, next_middleware)

  local response = next_middleware()
  local events = json.decode(response.body)
  local newresponse ={}

  for i=1,#events do
    local currentEvent = events[i];

    for j=1,#currentEvent.occurrence_set do
      table.insert(newresponse,{
        title       = currentEvent.title,
        desc        = currentEvent.description,
        id          = currentEvent.id,
        host        = currentEvent.hosted_by_camp,
        url         = currentEvent.url,
        location    = currentEvent.other_location,
        category    = currentEvent.event_type.abbr,
        start_time  = currentEvent.occurrence_set[j].start_time,
        end_time    = currentEvent.occurrence_set[j].end_time
      })
    end
  end

  response.body = json.encode(newresponse)

  return response
end
