local M = {}
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local rep = require("luasnip.extras").rep
local function to_lower(args)
  return string.lower(args[1][1])
end

local function pascal_to_snake(args)
  local str = args[1][1]
  str = str:gsub("(%u)", "_%1"):lower()
  return str:gsub("^_", "")
end

M.remote_function_call = s({ trig = "remoteCall", name = "Call Remote Function" }, {
  t("try {"),
  t({ "", "  await " }),
  i(1, "remote_name"),
  t("({"),
  i(0),
  t("});"),
  t({ "", "} catch (error) {" }),
  t({ "", "  /* Handle Error */" }),
  t({ "", "}" }),
})

--[[
<button class={["btn btn-sm btn-ghost"]} onclick={() => {}}>
  NAME_0 
</button>
--]]
M.svelte_button = s({ trig = "btn", name = "Html Button" }, {
  t('<button class={["btn btn-sm btn-ghost"]} onclick={() => {'),
  t({ "}}>" }),
  t({ "", "  " }),
  i(0, "Label"),
  t({ "", "</button>" }),
})

--[[
 		{#each items_1 as item, i (item)}
			{@render snippet_name_2(item)}
		{/each}

    {#snippet snippet_name_2(params: {})}
      END
    {/snippet}
--]]
M.svelte_each = s({ trig = "templateEach", name = "Html Each (For)" }, {
  t("{#each "),
  i(1, "items"),
  t(" as item, i (item)}"),
  t({ "", "  {@render " }),
  i(2, "snippet_name"),
  t("(item)}"),
  t({ "", "{/each}" }),
  t({ "", "" }),
  t("{#snippet "),
  rep(2),
  t("(params: {})}"),
  t({ "", "  " }),
  i(0),
  t({ "", "{/snippet}" }),
})

--[[
<script lang="ts">
	import { page } from '$app/state';

	interface Props {
		children?: import('svelte').Snippet;
	}

	let { children }: Props = $props();

  const {} = $derived(page.data)
</script>

<div class={[""]}>
  Component works
</div>

<style>

</style>

<!--
END
-->
--]]
M.svelte_component = s({ trig = "svelteComp", name = "Svelte Component Template" }, {
  t('<script lang="ts">'),
  t({ "", "  import { page } from '$app/state';", "" }),
  t("  interface Props {"),
  t({ "", "    children?: import('svelte').Snippet;", "  }", "" }),
  t({ "  let { children }: Props = $props();", "" }),
  t("  const {} = $derived(page.data)"),
  t({ "", "</script>", "" }),
  t('<div class={[""]}>'),
  t({ "", "  " }),
  t("Component works"),
  t({ "", "</div>", "", "" }),
  t("<style>"),
  t({ "", "" }),
  t({ "</style>", "", "" }),
  t("<!--"),
  t({ "", "" }),
  i(0),
  t({ "", "-->" }),
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
  t({ ";", "export const state_" }),
  f(to_lower, { 1 }),
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

local snippets = {}
for key, snippet in pairs(M) do
  table.insert(snippets, snippet)
end

return snippets
