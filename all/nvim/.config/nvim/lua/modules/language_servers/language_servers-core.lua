local M = {}

local svelte_ls = require("modules.language_servers.language_servers-svelte")

M.lsp_config = {
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        svelte = svelte_ls.svelte_setup, -- + LazyExtras
      },
    },
  },
}

return M
