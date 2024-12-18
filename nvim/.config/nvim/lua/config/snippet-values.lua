-- Icon Color: azure, blue, cyan, green, grey, orange, purple, red, yellow

local if_ts = [[if ($1) {
  $0
}]]
local if_lua = [[if ($1) then
  $0
end]]
local svelte_state = [[#$1 = \$state($2)
this.#$1 = $1;
$0get $1() {
  return this.#$1
},
set $1(value) {
  this.#$1 = value
},
]]

-- PERF: Add a class to identify autocmd
local M = {
  {
    body = if_ts,
    desc = "If Statement",
    icon = { icon = "󰈸", color = "yellow" },
    key = "<leader>m3",
  },
  {
    body = if_lua,
    desc = "If Statement",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>m2",
  },
  {
    body = svelte_state,
    desc = "Getter / setter private class state",
    icon = { icon = "", color = "orange" },
    key = "<leader>msg",
  },
}
return M
