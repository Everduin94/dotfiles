
local M = {}

function M.readAll(command)
  local handle = io.popen(command);
  local result = handle:read("*a"); -- *a reads whole file
  handle:close();
  return result;
end

function M.readLines(command)
  local handle = io.popen(command);
  local result = handle:read("*l");
  handle:close();
  return result;
end

function M.escape(...)
 local command = type(...) == 'table' and ... or { ... }
 for i, s in ipairs(command) do
  s = (tostring(s) or ''):gsub('"', '\\"')
  if s:find '[^A-Za-z0-9_."/-]' then
   s = '"' .. s .. '"'
  elseif s == '' then
   s = '""'
  end
  command[i] = s
 end
 return table.concat(command, ' ')
end

return M

