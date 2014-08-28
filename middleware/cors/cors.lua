return function (request, next_middleware)
  local res = next_middleware()
  -- Allow origin from certain domains (change as required)
  res.headers['Access-Control-Allow-Origin'] = "http://domain1.com http://domain2.com"
  -- Anable all domains (uncomment and comment the previous one if required)
  -- res.headers['Access-Control-Allow-Origin'] = "*"
  return res
end
