local M = {}

M.lsp_config = {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        float = {
          border = "rounded",
        },
      },
      inlay_hints = { enabled = false },
    },
  },
}

return M
