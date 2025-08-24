local M = {}

M.if_block = [[{#if $1} 
  $0
{/if}]]

M.else_block = [[{:else}
  $0]]

M.else_if = [[{:else if $1} 
  $0]]

M.for_block = [[{#each $1 as item, i (item.id)}
  $0
{/each}]]

M.for_n = [[{#each { length: $1 }, i }
  $0
{/each}]]

M.if_lua = [[if ($1) then
  $0
end]]

M.derive_state = [[let $1_state = \$derived(get${1/(.)(.*)/${1:/upcase}${2}/}State())
let {$2} = \$derived($1_state)]]

M.state = [[#$1 = \$state($2)
if (opts.$1) this.#$1 = opts.$1;
$0get $1() {
  return this.#$1
}
set $1(value) {
  this.#$1 = value
}
]]

M.state2 = [[
$1: $2;
$0$1 = \$state<$2>($3)
if (opts.$1) this.$1 = opts.$1;
]]

M.class = [[import { getContext, setContext } from "svelte";

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

M.class_no_context = [[interface $1Opts {

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

return M
