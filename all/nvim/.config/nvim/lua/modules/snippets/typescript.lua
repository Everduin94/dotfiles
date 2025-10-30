local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local i = ls.insert_node
local t = ls.text_node
local d = ls.dynamic_node
local s = ls.snippet
local f = ls.function_node
local sn = ls.snippet_node

-- TODO: Util
local function selected_text()
  return f(function(_, parent)
    return parent.snippet.env.LS_SELECT_RAW or ""
  end)
end

local M = {}

-- console.log(`variable`, variable);
M.log_variable = s(
  { trig = "logv", name = "Console Log Variable" },
  fmt("console.log(`{}`, {});", {
    rep(1),
    i(1),
  })
)

-- console.log(`variable`);
M.log_variable = s(
  { trig = "logv", name = "Console Log" },
  fmt("console.log(`{}`, {});", {
    rep(1),
    i(1),
  })
)

M.if_statement = s({ trig = "if", name = "If Statement (Mine)" }, {
  t("if ("),
  i(1, "condition"),
  t({ ") {", "  " }),
  selected_text(),
  i(0),
  t({ "", "}" }),
})

local snippets = {}
for key, snippet in pairs(M) do
  table.insert(snippets, snippet)
end

return snippets
