local Model = {}

function Model:new()
  return {
    new = function() return {} end
  }
end

function Model.build_excluded_fields()
  return {}
end

return Model
