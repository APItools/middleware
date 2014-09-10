-- query string module. inspired in luacgi code --
local string = require ("string")

local QueryString = {}

local function escapeURI(s)
  s = string.gsub (s, "\n", "\r\n")
  s = string.gsub (s, "([^0-9a-zA-Z ])", -- locale independent
  function (c) return string.format ("%%%02X", string.byte(c)) end)
  s = string.gsub (s, " ", "+")
  return s
end

local function binsert(buffer, blen, str)
  blen = blen + 1
  buffer[blen] = str
  return blen
end

local function stringifyPrimitive(p)
  local t = type(p)
  if t == "boolean" or t == "number" then
    return tostring(p)
  elseif t == "string" then
    return escapeURI(p)
  else
    error("Unknown type to stringify: " .. t .. "(" .. tostring(s) .. ")")
  end
end

local function qinsert(args, str)
  local first = str:find("=")
  if first then
    args[str:sub(0, first-1)] = str:sub(first+1)
  end
end

local function get_keys(t)
  local keys, klen = {}, 0
  for k in pairs(t) do
    klen = klen + 1
    keys[klen] = k
  end
  return keys, klen
end

-----------------------------

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
  local args, pos = {}, 0

  -- XXX this is wrong
  query = query:gsub("&amp;", "&")
  query = query:gsub("&lt;", "<")
  query = query:gsub("&gt;", ">")

  while true do
    local first, last = query:find("&", pos)
    if first then
      qinsert(args, query:sub(pos, first-1));
      pos = last+1
    else
      qinsert(args, query:sub(pos));
      break;
    end
  end
  return args
end

QueryString.decode = QueryString.parse

function QueryString.stringify(obj, sep, eq)
  sep = sep or '&'
  eq  = eq  or '='

  local keys, klen = get_keys(obj)
  if klen == 0 then return '' end
  table.sort(keys)

  local buf, blen = {}, 0

  local k,v
  for i=1, klen do
    k = keys[i]
    v = obj[k]
    if i > 1 then blen = binsert(buf, blen, sep) end
    blen = binsert(buf, blen, stringifyPrimitive(k))
    blen = binsert(buf, blen, eq)
    blen = binsert(buf, blen, stringifyPrimitive(v))
  end

  return table.concat(buf)
end

QueryString.encode = QueryString.stringify

return QueryString
