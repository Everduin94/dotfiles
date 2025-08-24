local strings = require("modules.snippets.svelte.strings-svelte")

local M = {
  {
    body = strings.if_block,
    desc = "If svelte block",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mfq",
  },
  {
    body = strings.else_block,
    desc = "Else svelte block",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mfw",
  },
  {
    body = strings.else_if,
    desc = "Else if svelte block",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mfe",
  },
  {
    body = strings.for_block,
    desc = "Each svelte block",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mfr",
  },
  {
    body = strings.for_n,
    desc = "Each N svelte block",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mft",
  },
  {
    body = strings.derive_state,
    desc = "getXyzState() derived helper",
    icon = { icon = "", color = "orange" },
    key = "<leader>msd",
  },
  {
    body = strings.state,
    desc = "Getter / setter private class state",
    icon = { icon = "", color = "orange" },
    key = "<leader>msg",
  },
  {
    body = strings.state2,
    desc = "Magic getter setter",
    icon = { icon = "", color = "orange" },
    key = "<leader>msG",
  },
  {
    body = strings.class,
    desc = "Class + Context Pattern",
    icon = { icon = "", color = "orange" },
    key = "<leader>msc",
  },
  {
    body = strings.class_no_context,
    desc = "Class + Assert Pattern",
    icon = { icon = "", color = "orange" },
    key = "<leader>msC",
  },
}

return M
