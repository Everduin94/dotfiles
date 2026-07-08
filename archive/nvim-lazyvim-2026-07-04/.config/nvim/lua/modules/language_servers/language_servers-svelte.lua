local M = {}

M.svelte_setup = function(_, opts)
  LazyVim.lsp.on_attach(function(client)
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.js", "*.ts" },
      callback = function(ctx)
        client:notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
      end,
    })
  end)
  opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
    svelte = {
      plugin = {
        svelte = {
          format = {
            config = {
              svelteBracketNewLine = false,
            },
          },
          plugin = {
            typescript = {
              enabled = true,
              diagnostics = { enable = true },
            },
          },
        },
      },
    },
  })
end

return M
