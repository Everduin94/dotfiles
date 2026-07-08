local M = {}

local oxc_filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "jsonc",
  "css",
  "scss",
  "less",
  "html",
  "yaml",
  "markdown",
  "markdown.mdx",
  "vue",
  "svelte",
  "astro",
}

--   "json",

local oxc_root_markers = {
  ".oxfmtrc.json",
  ".oxfmtrc.jsonc",
  "oxfmt.config.ts",
  ".oxlintrc.json",
  ".oxlintrc.jsonc",
  "oxlint.config.ts",
}

--[[
--
  ".editorconfig",
  "package.json",
  "package-lock.json",
  "pnpm-lock.yaml",
  "yarn.lock",
  "bun.lock",
  "bun.lockb",
  "nx.json",
  ".git",
--
--]]

local function oxc_root_dir(bufnr, on_dir)
  on_dir(vim.fs.root(bufnr, oxc_root_markers) or vim.fn.getcwd())
end

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
      servers = {
        -- oxfmt = {
        --   root_dir = oxc_root_dir,
        -- },
        -- oxlint = {
        --   root_dir = oxc_root_dir,
        -- },
      },
    },
  },
  -- {
  --   "stevearc/conform.nvim",
  --   optional = true,
  --   opts = function(_, opts)
  --     opts.formatters_by_ft = opts.formatters_by_ft or {}
  --     for _, filetype in ipairs(oxc_filetypes) do
  --       opts.formatters_by_ft[filetype] = { "oxfmt" }
  --     end
  --
  --     opts.formatters = opts.formatters or {}
  --     opts.formatters.oxfmt = {
  --       cwd = require("conform.util").root_file(oxc_root_markers),
  --     }
  --   end,
  -- },
}

return M
