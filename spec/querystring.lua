-- query string module. inspired in luacgi code --
local string = require ("string")

local QueryString = {}

function escapeURI(s)
  s = string.gsub (s, "\n", "\r\n")
  s = string.gsub (s, "([^0-9a-zA-Z ])", -- locale independent
  function (c) return string.format ("%%%02X", string.byte(c)) end)
  s = string.gsub (s, " ", "+")
  return s
end

function QueryString.escape(s)
  return escapeURI(s)
end

function QueryString.unescapeBuffer(s)
  s = string.gsub (s, "+", " ")
  s = string.gsub (s, "%%(%x%x)",
    function(h)
      return string.char(tonumber(h,16))
    end)
  s = string.gsub (s, "\r\n", "\n")
  return s
end

function QueryString.unescape(s, decodeSpaces)
  return QueryString.unescapeBuffer(s) -- ignored decodeSpaces)
end

function QueryString.parse(query)
  local parsed = {}
  local pos = 0

  -- XXX this is wrong
  query = query:gsub("&amp;", "&")
  query = query:gsub("&lt;", "<")
  query = query:gsub("&gt;", ">")

  local function ginsert(qstr)
    local first, last = qstr:find("=")
    if first then
      parsed[qstr:sub(0, first-1)] = qstr:sub(first+1)
    end
  end

  while true do
    local first, last = query:find("&", pos)
    if first then
      ginsert(query:sub(pos, first-1));
      pos = last+1
    else
      ginsert(query:sub(pos));
      break;
    end
  end
  return parsed
end

function QueryString.decode(obj, sep, eq)
  return parse(obj, sep, eq)
end

function stringifyPrimitive(s)
  local t = type(s)
  if t == "boolean" then
    if v then
      return "true"
    else
      return "false"
    end
  elseif t == "string" then
    return escapeURI(s)
  elseif t == "number" then
    return s
  end
  return ""
end

function QueryString.stringify(obj, sep, eq)
  if not sep then sep = '&' end
  if not eq then eq = '=' end
  s = ""
  for k,v in pairs(obj) do
    if type(v) == "table" then
      for k,u in pairs(v) do
        if not (s == "") then s = s..sep end
        s = s..stringifyPrimitive(k)..eq..stringifyPrimitive(u)
      end
    else
      if not (s == "") then s = s..sep end
      s = s..stringifyPrimitive(k)..eq..stringifyPrimitive(v)
    end
  end
  return s
end

function QueryString.encode(obj, sep, eq)
  return stringify(obj, sep, eq)
end

return QueryString
