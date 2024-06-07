-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#svelte
-- npm install -g svelte-language-server
-- npm install --save-dev typescript-svelte-plugin
require'lspconfig'.svelte.setup {
  on_attach = function(client)
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.js", "*.ts" },
      callback = function(ctx)
        client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
      end,
    })
  end
}
