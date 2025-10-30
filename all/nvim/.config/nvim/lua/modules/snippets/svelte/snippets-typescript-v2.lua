local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local i = ls.insert_node
local t = ls.text_node
local d = ls.dynamic_node
local s = ls.snippet
local f = ls.function_node
local sn = ls.snippet_node

local function selected_text()
  return f(function(_, parent)
    return parent.snippet.env.LS_SELECT_RAW or ""
  end)
end

local M = {
  -- console.log('variable', variable);
  s(
    { trig = "xxxx", name = "XXX" },
    fmt("console.log('{}', {});", {
      rep(1),
      i(1),
    })
  ),
}

return snippets
