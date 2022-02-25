local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions

null_ls.setup({
	sources = {
		formatting.prettierd,
		formatting.eslint_d,
		code_actions.eslint_d,
    diagnostics.eslint_d,
	},
})

-- Format on save, timeout if longer than 1s
vim.cmd [[
  autocmd BufWritePre *.ts,*.html,*.scss lua vim.lsp.buf.formatting_sync(nil, 1000)
]]
