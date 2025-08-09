-- Icon Color: azure, blue, cyan, green, grey, orange, purple, red, yellow

local if_ts = [[if ($1) {
  $0
}]]
local else_ts = [[else {
  $0
}]]
local else_if_ts = [[else if ($1) {
  $0
}]]
local for_i_ts = [[for (let i = 0; i < $1.length; i++) {
  const item = $1[i];
  $0
}]]
local for_ts = [[for (const item of $1) {
  $0
}]]
local try_ts = [[try {
  $0
} catch(err) {
  console.error(err);
}]]
local if_svelte = [[{#if $1} 
  $0
{/if}]]
local else_svelte = [[{:else}
  $0]]
local else_if_svelte = [[{:else if $1} 
  $0]]
local for_svelte = [[{#each $1 as item, i (item.id)}
  $0
{/each}]]
local for_n_svelte = [[{#each { length: $1 }, i }
  $0
{/each}]]
local if_lua = [[if ($1) then
  $0
end]]
-- Note. This works because you expand with lua snippet. IF you expand with vim, as of this version, doesn't work.
local derive_state_svelte = [[let $1_state = \$derived(get${1/(.)(.*)/${1:/upcase}${2}/}State())
let {$2} = \$derived($1_state)]]

local fffff = [[$1 (${1/(.*)/${1:/upcase}/}) $0]]
local svelte_state = [[#$1 = \$state($2)
if (opts.$1) this.#$1 = opts.$1;
$0get $1() {
  return this.#$1
}
set $1(value) {
  this.#$1 = value
}
]]
local svelte_state_2 = [[
$1: $2;
$0$1 = \$state<$2>($3)
if (opts.$1) this.$1 = opts.$1;
]]
local svelte_class = [[import { getContext, setContext } from "svelte";

interface $1Opts {

}

export class $1 {
  constructor(opts: $1Opts) {
    
  }
}

const $1Key = Symbol('$1')
export function set$1(opts: $1Opts) {
  return setContext($1Key, new $1(opts));
}
export function get$1() {
  return getContext<ReturnType<typeof set$1>>($1Key);
}
]]
local svelte_class_no_context = [[interface $1Opts {

}

export class $1 {
  constructor(opts: Partial<$1Opts>) {
    
  }
}

let $2: $1 | null = $state(null);
export function set$1(opts: $1Opts) {
	$2 = new $1(opts);
}
export function get$1(): $1 {
	if (!$2) throw new Error('Tried to access $1 before set');
	return $2;
}
]]

-- PERF: Add a class to identify autocmd
local M = {
  {
    body = if_ts,
    desc = "If statement",
    icon = { icon = "󰈸", color = "yellow" },
    key = "<leader>mf1",
  },
  {
    body = else_ts,
    desc = "Else statement",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mf2",
  },
  {
    body = else_if_ts,
    desc = "Else if statement",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mf3",
  },
  {
    body = for_i_ts,
    desc = "For loop by index",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mf4",
  },
  {
    body = for_ts,
    desc = "For of loop",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mf5",
  },
  {
    body = try_ts,
    desc = "Try catch",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mf6",
  },
  {
    body = if_svelte,
    desc = "If svelte block",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mfq",
  },
  {
    body = else_svelte,
    desc = "Else svelte block",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mfw",
  },
  {
    body = else_if_svelte,
    desc = "Else if svelte block",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mfe",
  },
  {
    body = for_svelte,
    desc = "Each svelte block",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mfr",
  },
  {
    body = for_n_svelte,
    desc = "Each N svelte block",
    icon = { icon = "󰈸", color = "orange" },
    key = "<leader>mft",
  },
  {
    body = derive_state_svelte,
    desc = "getXyzState() derived helper",
    icon = { icon = "", color = "orange" },
    key = "<leader>msd",
  },
  {
    body = svelte_state,
    desc = "Getter / setter private class state",
    icon = { icon = "", color = "orange" },
    key = "<leader>msg",
  },
  {
    body = svelte_state_2,
    desc = "Magic getter setter",
    icon = { icon = "", color = "orange" },
    key = "<leader>msG",
  },
  {
    body = svelte_class,
    desc = "Class + Context Pattern",
    icon = { icon = "", color = "orange" },
    key = "<leader>msc",
  },
  {
    body = svelte_class_no_context,
    desc = "Class + Assert Pattern",
    icon = { icon = "", color = "orange" },
    key = "<leader>msC",
  },
}
return M
