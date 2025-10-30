local M = {}
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local i = require("luasnip").insert_node
local s = require("luasnip").snippet

M.log = s(
  "l",
  fmt("console.log('{}');", {
    i(1),
  })
)

M.log_var = s(
  "l2",
  fmt("console.log('{}', {});", {
    rep(1),
    i(1),
  })
)

return M
