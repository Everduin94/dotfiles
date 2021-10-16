-- npm install -g eslint_d
-- brew install efm-langserver
local lsp = require('lspconfig')

local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true,
  debounce = 500,
}
local prettier = { formatCommand = 'prettier ./node_modules/.bin/prettier --stdin-filepath ${INPUT}', formatStdin = true }

-- Format on save (copy paste: https://github.com/gitneeraj/dotfiles/blob/develop/nvim.lua/lua/modules/efm/init.lua)
local format_async = function(err, _, result, _, bufnr)
    if err ~= nil or result == nil then return end
    if not vim.api.nvim_buf_get_option(bufnr, "modified") then
        local view = vim.fn.winsaveview()
        vim.lsp.util.apply_text_edits(result, bufnr)
        vim.fn.winrestview(view)
        if bufnr == vim.api.nvim_get_current_buf() then vim.api.nvim_command("noautocmd :update") end
    end
end

vim.lsp.handlers["textDocument/formatting"] = format_async


local function eslint_config_exists()
  local eslintrc = vim.fn.glob(".eslintrc*", 0, 1)

  if not vim.tbl_isempty(eslintrc) then
    return true
  end

  if vim.fn.filereadable("package.json") then
    if vim.fn.json_decode(vim.fn.readfile("package.json"))["eslintConfig"] then
      return true
    end
  end

  return false
end

-- Servers With Custom Overrides changed eslintrc.js to eslintrc.json

lsp.efm.setup {
  init_options = {documentFormatting = true},
  filetypes = {"javascript", "typescript", "html", "css", "scss"},
  root_dir = function()
    if not eslint_config_exists() then
      return nil
    end
    return vim.fn.getcwd()
  end,
  settings = {
    rootMarkers = { ".eslintrc.json", ".git/"},
    languages = {
      javascript = {eslint},
      typescript = {eslint},
      css = { prettier },
      html = { prettier },
    }
  }
}
