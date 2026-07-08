local capabilities = vim.lsp.protocol.make_client_capabilities()

if capabilities.workspace then
  capabilities.workspace.didChangeWatchedFiles = nil
end

vim.lsp.config("*", {
  capabilities = capabilities,
})

vim.lsp.enable({
  "ts_ls",
  "html",
  "cssls",
  "angularls",
  "svelte",
  "tailwindcss",
  "eslint",
  "lua_ls",
})
