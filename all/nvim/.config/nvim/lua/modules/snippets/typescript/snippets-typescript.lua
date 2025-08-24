local strings = require("modules.snippets.typescript.strings-typescript")

local M = {
  {
    body = strings.if_statement,
    desc = "If statement",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>mf1",
  },
  {
    body = strings.else_statement,
    desc = "Else statement",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>mf2",
  },
  {
    body = strings.else_if,
    desc = "Else if statement",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>mf3",
  },
  {
    body = strings.for_index,
    desc = "For loop by index",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>mf4",
  },
  {
    body = strings.for_of,
    desc = "For of loop",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>mf5",
  },
  {
    body = strings.try_catch,
    desc = "Try catch",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>mf6",
  },
}

return M
