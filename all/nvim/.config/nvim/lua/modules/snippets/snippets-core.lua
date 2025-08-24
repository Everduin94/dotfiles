local M = {}

M.luasnip = {
  "L3MON4D3/LuaSnip",
  build = (not LazyVim.is_win())
      and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
    or nil,
  opts = {
    history = true,
    delete_check_events = "TextChanged",
  },
  init = function()
    local ls = require("luasnip")
    local svelte_snippets = require("modules.snippets.svelte.snippets-svelte")
    local typescript_snippets = require("modules.snippets.typescript.snippets-typescript")
    local util = require("modules.snippets.snippets-util")

    ls.add_snippets("svelte", util.to_snippets(svelte_snippets), { key = "svelte" })
    ls.add_snippets("typescript", util.to_snippets(typescript_snippets), { key = "typescript" })
  end,
}

return M
