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
    ls.setup({
      -- cut_selection_keys = "<C-s>",
      ext_opts = {
        [require("luasnip.util.types").snippet] = {
          active = {
            virt_text = { { "●", "AlphaShortcut" } },
          },
        },
      },
    })
    local svelte_snippets = require("modules.snippets.svelte.snippets-svelte")
    local angular_snippets = require("modules.snippets.angular.snippets-angular")
    local typescript_snippets = require("modules.snippets.typescript.snippets-typescript")
    local util = require("modules.snippets.snippets-util")
    local is_angular = next(vim.fs.find({ "angular.json", "nx.json" }, { upward = true }))
    local is_svelte = next(vim.fs.find({ "svelte.config.js", "svelte.config.ts" }, { upward = true }))

    if is_angular then
      local angular_plus_ts = vim.tbl_extend("force", typescript_snippets, angular_snippets)
      ls.add_snippets("typescript", util.to_snippets(angular_plus_ts), { key = "typescript" })
      ls.add_snippets("html", util.to_snippets(angular_snippets), { key = "html" })
    elseif is_svelte then
      ls.add_snippets("svelte", util.to_snippets(svelte_snippets), { key = "svelte" })
      ls.add_snippets("typescript", util.to_snippets(typescript_snippets), { key = "typescript" })
    else
      ls.add_snippets("typescript", require("modules.snippets.typescript"), { key = "typescript" })
      -- ls.add_snippets("typescript", require("modules.snippets.svelte.snippets-typescript-v2"), { key = "typescript" })
    end
  end,
}

-- s(
--   { trig = "10", desc = "A detailed description yo", name = "Console log" },
--   fmt("console.log('{}', {});", {
--     rep(1),
--     i(1),
--   })
-- ),
-- s("ifxx", {
--   t("if ("),
--   i(1, "condition"),
--   t({ ") {", "  " }),
--   selected_text(),
--   t({ "", "}" }),
-- }),

return M
