-- npm install eslint_d -g
-- eslint_d restart

local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

vim.lsp.set_log_level("info")

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions

null_ls.setup({
	sources = {
		formatting.prettierd,
	},
  on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format({
                      filter = function(client)
                          -- apply whatever logic you want (in this example, we'll only use null-ls)
                          return client.name == "null-ls"
                      end,
                      bufnr = bufnr,
                  })
                end,
            })
        end
    end,
})

-- Format on save, timeout if longer than 1s | Update: pre .8
-- vim.cmd [[
--   autocmd BufWritePre *.ts,*.html,*.scss lua vim.lsp.buf.formatting_sync(nil, 1000)
-- ]]
