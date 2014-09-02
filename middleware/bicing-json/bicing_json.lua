--[[
--
-- This middleware converts Bicing XML to JSON.
--
--]]

local function parse_xml(xml, xml_string)
  local stations = {}
  local station
  local attribute

  local parser = xml.new({
    StartElement = function(parser, tag, attrs)
      if tag == 'station' then
        station = {}
      elseif station then
        attribute = tag
      end
    end,
    CharacterData = function(parser, value)
      if station and attribute then
        station[attribute] = value
        attribute = nil
      end
    end,
    EndElement = function(parser, tag)
      if tag == 'station' then
        stations[#stations + 1] = station
        station = nil
      end
      attribute = nil
    end
  })
  parser:parse(xml_string)

  return stations
end

return function(request, next_middleware)
  local response = next_middleware()
  response.body = json.encode(parse_xml(xml, response.body))
  return response
end
