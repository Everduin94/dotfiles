local strings = require("modules.snippets.typescript.strings-typescript")

local M = {
  -- FLOW
  ts_if_statement = {
    body = strings.if_statement,
    desc = "If statement",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>m1",
  },
  ts_else_statement = {
    body = strings.else_statement,
    desc = "Else statement",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>m2",
  },
  ts_else_if = {
    body = strings.else_if,
    desc = "Else if statement",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>m3",
  },
  ts_for_of = {
    body = strings.for_of,
    desc = "For of loop",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>m4",
  },
  ts_for_index = {
    body = strings.for_index,
    desc = "For loop by index",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>m5",
  },
  ts_try_catch = {
    body = strings.try_catch,
    desc = "Try catch",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>m6",
  },

  -- ALL
  ts_log = {
    body = strings.log,
    desc = "Log",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>ml",
  },

  ts_log_var = {
    body = strings.log_var,
    desc = "Log Var",
    icon = { icon = "󰈸", color = "blue" },
    key = "<leader>mlv",
  },
}

return M
