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

vim.lsp.enable("ts_ls")
vim.lsp.enable("svelte")
vim.lsp.enable("copilot")

-- Throws error: attempt to index field 'inline_completion' (a nil value)
-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(args)
--     local bufnr = args.buf
--     local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
--
--     if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
--       vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
--
--       vim.keymap.set(
--         "i",
--         "<C-F>",
--         vim.lsp.inline_completion.get,
--         { desc = "LSP: accept inline completion", buffer = bufnr }
--       )
--       vim.keymap.set(
--         "i",
--         "<C-G>",
--         vim.lsp.inline_completion.select,
--         { desc = "LSP: switch inline completion", buffer = bufnr }
--       )
--     end
--   end,
-- })
