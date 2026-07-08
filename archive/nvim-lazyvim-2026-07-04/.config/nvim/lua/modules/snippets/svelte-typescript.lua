local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

local M = {}

local function pascal_to_snake(args)
  local str = args[1][1]
  str = str:gsub("(%u)", "_%1"):lower()
  return str:gsub("^_", "")
end

M.remote_function_command = s({ trig = "remoteCommand", name = "Remote Function: Command" }, {
  t("import * as v from 'valibot';"),
  t({ "", "" }),
  t("import { getRequestEvent, command } from '$app/server';"),
  t({ "", "" }),
  t({ "", "" }),
  t("const schema = v.object({});"),
  t({ "", "" }),
  t({ "", "" }),
  t("/*"),
  t({ "", "* " }),
  i(1, "Description"),
  t({ "", "*/", "" }),
  t("export const "),
  i(2, "remote_name"),
  t(" = command(schema, async (params) => {"),
  t({ "", "  const { cookies } = getRequestEvent();" }),
  t({ "", "  " }),
  i(0),
  t({ "", "});" }),
})

--[[
class StateCta {

	constructor() {}
}

export const state_cta = new StateCta();
--]]
M.state_class = s({ trig = "stateClass", name = "State Class Svelte" }, {
  t("class "),
  i(1, "Name"),
  i(0),
  t({ " {", "", "\tconstructor() {}", "", "}", "", "", "export const " }),
  f(pascal_to_snake, { 1 }),
  t(" = new "),
  rep(1),
  t("();"),
})

--[[
  type NAMEStates = "default";
  type NAMEEvents = "toggle";
  export const stateNAME = new FiniteStateMachine<NAMEStates, NAMEEvents>(
    "default",
    {
      default: {
        toggle: "default",
      },
    },
  );
--]]
M.finite_state_machine = s({ trig = "fsm", name = "Finite State Machine" }, {
  t("type "),
  i(1, "Name"),
  t("States = "),
  t('"default"'),
  t({ ";", "type " }),
  rep(1),
  t("Events = "),
  t('"toggle"'),
  t({ ";", "export const state" }),
  rep(1),
  t(" = new FiniteStateMachine<"),
  rep(1),
  t("States"),
  t(", "),
  rep(1),
  t("Events"),
  t(">("),
  t({ "", '  "default",', "  {" }),
  t({ "", "    default: {" }),
  t({ "", "      toggle: 'default'" }),
  rep(2),
  t({ ",", "    }," }),
  t({ "", "  }," }),
  t({ "", ");" }),
})

M.persisted_state = s({ trig = "persistedState", name = "Persisted State" }, {
  i(1, "name"),
  t(" = new PersistedState('"),
  rep(1),
  t("', '"),
  i(3, "default"),
  t("');"),
})

local snippets = {}
for key, snippet in pairs(M) do
  table.insert(snippets, snippet)
end

return snippets
