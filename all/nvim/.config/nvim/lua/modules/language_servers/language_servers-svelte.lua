local M = {}

M.svelte_setup = function(_, opts)
  LazyVim.lsp.on_attach(function(client, buffer)
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.js", "*.ts" },
      callback = function(ctx)
        client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
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
        },
      },
    },
  })
end

return M
