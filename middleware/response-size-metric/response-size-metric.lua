--[[
--
-- This middleware adds a metric called "size", containing the request size.
-- This metric can be latter used on the Analytics tab, to plot more info.
--
-- You need to make at least one request using this middleware before it is possible to make the graph.
-- Once the request is done, the graph in the analytics tab can be built like this:
--
-- * Title: Response Size
-- * Time Range: 30 min
-- * Granularity: 1min
-- * Metrics: Size (It won't appear until at least one request has been made using the new middleware)
-- * Activate the "avg" flag, just below "size"
-- * Methods: Deactivate all, but activate "One line per method"
-- * Paths: Activate 1 line per path
--
-- Now there should be a graph that displays the response size of each endpoint.
-- The response will be averaged by granularity; this means that if the send endpoint returns several
-- responses of different sizes, their averabe per minute/hour/day will be shown.
--
--]]

return function(request, next_middleware)
  local response = next_middleware()
  metric.set('size', #response.body)
  return response
end
