vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  pattern = { "*" },
  command = "lua vim.highlight.on_yank({higroup='IncSearch', timeout = 2000}) ",
})

vim.api.nvim_create_autocmd({ "BufWrite" }, {
  pattern = { "+page.server.ts", "+page.ts", "+layout.server.ts", "+layout.ts" },
  command = "LspRestart svelte",
})

vim.api.nvim_set_hl(0, "LspReferenceText", {})

local map = LazyVim.safe_keymap_set
function set_term_keymaps()
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-[>", [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
  map("t", [[<C-\>]], [[<C-\><C-n>]], { desc = "Escape Terminal" })
end

vim.cmd("autocmd! TermOpen term://* lua set_term_keymaps()")
