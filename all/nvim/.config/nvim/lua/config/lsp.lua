-- zig.vim: disable its own fmt-on-save/parse-error popups; ZLS handles formatting
vim.g.zig_fmt_parse_errors = 0
vim.g.zig_fmt_autosave = 0

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
  "zls",
})
