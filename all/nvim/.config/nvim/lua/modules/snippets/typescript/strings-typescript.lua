local M = {}
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local i = require("luasnip").insert_node
local s = require("luasnip").snippet

M.if_statement = [[if ($1) {
  $0
}]]

M.else_statement = [[else {
  $0
}]]

M.else_if = [[else if ($1) {
  $0
}]]

M.for_index = [[for (let i = 0; i < $1.length; i++) {
  const item = $1[i];
  $0
}]]

M.for_of = [[for (const item of $1) {
  $0
}]]

M.try_catch = [[try {
  $1
} catch(err) {
  $0
}]]

-- Luasnip style so that we can type in position 2 for intellisense and then repeat to position 2.
M.log = s(
  "ma1",
  fmt("console.log('{}');", {
    i(1),
  })
)

M.log_var = s(
  "ma1",
  fmt("console.log('{}', {});", {
    rep(1),
    i(1),
  })
)

return M
