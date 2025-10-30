local M = {}

local svelte_ls = require("modules.language_servers.language_servers-svelte")

M.lsp_config = {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        float = {
          border = "rounded",
        },
      },
      setup = {
        svelte = svelte_ls.svelte_setup, -- + LazyExtras
        vtsls = function(_, opts)
          local util = require("lspconfig.util")
          opts.root_dir = function(fname)
            -- Is '.' right here?
            return util.root_pattern("nx.json")(fname)
              or vim.fs.dirname(vim.fs.find("git", { path = ".", upward = true })[1])
          end

          return false -- Let LazyVim handle the actual setup
        end,
      },
      inlay_hints = { enabled = false },
    },
  },
}

return M
