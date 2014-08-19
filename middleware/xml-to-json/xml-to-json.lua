--[[
--
-- This middleware transforms xml requests into json requests.
--
-- Find more about it in the APItools blog: https://docs.apitools.com/blog/2014/05/06/transforming-an-rss-feed-into-json-with-apitools.html
--
--]]

local function parse_xml(xml_string)
  local root      = {children = {}}
  local ancestors = {}

  local parser = xml.new({
    StartElement = function(parser, tag, attrs)
      local node
      local parent = ancestors[#ancestors]
      if parent then
        node = {children = {}}
        parent.children[#parent.children + 1] = node
      else
        node = root
      end
      node.tag   = tag
      node.attrs = attrs
      ancestors[#ancestors + 1] = node
    end,
    CharacterData = function(parser, str)
      local parent   = ancestors[#ancestors]
      parent.children[#parent.children + 1] = str
    end,
    EndElement = function(parser, tag)
      ancestors[#ancestors] = nil
    end
  })
  parser:parse(xml_string)

  return root
end

return function(request, next_middleware)
  local response = next_middleware()
  local root     = parse_xml(response.body)

  response.body  = json.encode(root)
  response.headers['Content-type'] = 'application/json'
  return response
end
