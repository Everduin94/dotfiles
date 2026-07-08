local strings = require("modules.snippets.angular.strings-angular")

local M = {
  ng_if_block = {
    body = strings.if_block,
    desc = "If angular block",
    icon = { icon = "󰈸", color = "red" },
    key = "<leader>mfq",
  },
  ng_else_if = {
    body = strings.else_if,
    desc = "Else if angular block",
    icon = { icon = "󰈸", color = "red" },
    key = "<leader>mfw",
  },
  ng_else_block = {
    body = strings.else_block,
    desc = "Else angular block",
    icon = { icon = "󰈸", color = "red" },
    key = "<leader>mfe",
  },
  ng_for_block = {
    body = strings.for_block,
    desc = "Each angular block",
    icon = { icon = "󰈸", color = "red" },
    key = "<leader>mfr",
  },
  ng_for_n = {
    body = strings.for_n,
    desc = "Each N angular block",
    icon = { icon = "󰈸", color = "red" },
    key = "<leader>mfR",
  },
  -- STATE
  ng_state = {
    body = strings.state,
    desc = "Angular State",
    icon = { icon = "󰈸", color = "red" },
    key = "<leader>ms1",
  },
  ng_computed = {
    body = strings.computed_by,
    desc = "Angular Computed",
    icon = { icon = "󰈸", color = "red" },
    key = "<leader>ms2",
  },
  ng_computed_alt = {
    body = strings.computed_by,
    desc = "Angular Computed (alt)",
    icon = { icon = "󰈸", color = "red" },
    key = "<leader>ms@",
  },
  ng_effect = {
    body = strings.effect,
    desc = "Angular Effect",
    icon = { icon = "󰈸", color = "red" },
    key = "<leader>ms3",
  },
  ng_props = {
    body = strings.props,
    desc = "Angular Props",
    icon = { icon = "󰈸", color = "red" },
    key = "<leader>ms4",
  },
  ng_output = {
    body = strings.output,
    desc = "Angular Output",
    icon = { icon = "󰈸", color = "red" },
    key = "<leader>ms5",
  },
}

return M
