-- Highlight for longer (for webex)
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  pattern = { "*" },
  command = "lua vim.highlight.on_yank({higroup='IncSearch', timeout = 2000}) ",
})

-- Reload svelte files
vim.api.nvim_create_autocmd({ "BufWrite" }, {
  pattern = { "+page.server.ts", "+page.ts", "+layout.server.ts", "+layout.ts" },
  command = "LspRestart svelte",
})
