local metric = {}

function metric.new(spec)

  local instance = spec.metric or { counts = {}, sets = {} }
  spec.metric = instance

  instance.count = function(name, inc)
    instance.counts[name] = (instance.counts[name] or 0) + (inc or 1)
  end

  instance.set = function(name, value)
    instance.sets[name] = value
  end

end

return metric
