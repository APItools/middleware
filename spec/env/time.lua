local time = {}

function time.new(spec)
  local instance = {}

  instance.seconds = function()
    local now = spec.now or 0 -- we could use os.time() instead of 0 here; debugging is easier though
    spec.now = now
    return now
  end

  instance.now = instance.seconds

  instance.http = function(when)
    when = when or instance.seconds()
    -- Thu, 18 Nov 2010 11:27:35 GMT
    -- %e returns extra spaces for 1-digit days; remove them with gsub
    return (os.date("%a, %e %h %Y %H:%M:%S GMT", when):gsub("  ", " "))
  end

  return instance
end

return time
