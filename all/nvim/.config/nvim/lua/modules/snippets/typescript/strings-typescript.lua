local M = {}

M.if_statement = [[if ($1) {
  $0
}]]

M.else_statement = [[else {
  $0
}]]

M.else_if = [[else if ($1) {
  $0
}]]

M.for_index = [[for (let i = 0; i < $1.length; i++) {
  const item = $1[i];
  $0
}]]

M.for_of = [[for (const item of $1) {
  $0
}]]

M.try_catch = [[try {
  $0
} catch(err) {
  console.error(err);
}]]

return M
