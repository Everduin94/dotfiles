local M = {}
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

-- Generate sync function name from base function name
local function to_sync_name(args)
  return args[1][1] .. "_sync"
end

M.debounce_update = s({ trig = "debounceUpdate", name = "Debounced Update Pattern" }, {
  t("debounce_"),
  i(1, "update_item"),
  t(" = useDebounce("),
  t({ "", "\t(id: string, data: Partial<" }),
  i(2, "ItemType"),
  t(">) => {"),
  t({ "", "\t\t" }),
  f(to_sync_name, { 1 }),
  t("(id, data);"),
  t({ "", "\t}," }),
  t({ "", "\t() => " }),
  i(3, "300"),
  t({ "", ");" }),
  t({ "", "" }),
  rep(1),
  t("(id: string, data: Partial<"),
  rep(2),
  t(">) {"),
  t({ "", "\t" }),
  i(4, "arr"),
  t(" = "),
  rep(4),
  t(".map((item) => {"),
  t({ "", "\t\tif (item.id === id) {" }),
  t({ "", "\t\t\treturn { ...item, ...data };" }),
  t({ "", "\t\t}" }),
  t({ "", "\t\treturn item;" }),
  t({ "", "\t});" }),
  t({ "", "" }),
  t({ "", "\t" }),
  f(to_sync_name, { 1 }),
  t("(id, data);"),
  t({ "", "}" }),
  t({ "", "" }),
  i(0),
})

return M
