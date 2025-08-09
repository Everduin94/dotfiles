
local M = {}

-- stdlib
function M.trim(s, r)
   r = r or '%s+'
   return (string.gsub(string.gsub(s, '^' .. r, ''), r .. '$', ''))
end

return M
