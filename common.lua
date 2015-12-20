local _M = {}

local function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
       if s ~= 1 or cap ~= "" then
           table.insert(t,cap)
       end
       last_end = e+1
       s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
       cap = str:sub(last_end)
       table.insert(t, cap)
   end
   return t
end

function _M.incr_or_create(stats, key, count)
    local newval, err = stats:incr(key, count)
    if not newval and err == "not found" then
        stats:add(key, 0)
        stats:incr(key, count)
    end
end


function _M.key(key_table)
    return table.concat(key_table, ':')
end


function _M.in_table (value, table)
    for _, v in pairs(table) do
        if (v == value) then
            return true
        end
    end
    return false
end


function _M.format_response(key, value, response)
    local path = split(tostring(key), ':')
    key = table.remove(path, 1)
    if key == nil or key == '' then
         return value
    elseif response[key] == nil then
        response[key] = _M.format_response(_M.key(path), value, {})
    elseif response[key] ~= nil then
        response[key] = _M.format_response(_M.key(path), value, response[key])
    end
    return response
end


function _M.get_status_code_class(status)
  if     status:sub(1,1) == '1' then
      return "1xx"
  elseif status:sub(1,1) == '2' then
      return "2xx"
  elseif status:sub(1,1) == '3' then
      return "3xx"
  elseif status:sub(1,1) == '4' then
      return "4xx"
  elseif status:sub(1,1) == '5' then
      return "5xx"
  else
      return "xxx"
  end
end


function _M.update(stats, key, value)
    stats:set(key, value)
end


return _M
