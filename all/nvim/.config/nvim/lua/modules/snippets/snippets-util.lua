local ls = require("luasnip")

local M = {}

function M.remove_leader(input)
  return input:gsub("^<leader>", "")
end

function M.to_snippets(snippets)
  local tbl = {}
  for _, v in ipairs(snippets) do
    table.insert(tbl, ls.parser.parse_snippet({ trig = M.remove_leader(v.key) }, v.body))
  end
  return tbl
end

return M
