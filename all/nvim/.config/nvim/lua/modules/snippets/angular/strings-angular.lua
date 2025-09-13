local M = {}

M.if_block = [[@if ($1) {
  $0
}]]

M.else_block = [[@else {
  $0
}]]

M.else_if = [[@else if ($1) {
  $0
}]]

M.for_block = [[@for (let item of $1; track item.id) {
  $0
} @empty {
  No results found...
}]]

M.for_n = [[@for (let i of Array($1).keys()) {
  $0
}]]

-- STATE
M.state = [[const $1 = signal($2);$0]]
M.computed = [[const $1 = computed(() => $2);$0]]
M.computed_by = [[const $1 = computed(() => {
  $0
  return true;
});]]

M.props = [[
$1 = input.required<$2>($3);$0
]]

M.effect = [[effect(() => {
  $0
});]]
M.output = [[$1 = output<void>();$0 /* this.$1.emit() */]]

return M
