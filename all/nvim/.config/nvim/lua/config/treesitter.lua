local M = {}

local max_lines = 1200

-- Filetypes to drive with treesitter-based indent (`=`, autoindent, o/O).
-- Provided by the nvim-treesitter plugin (core `vim.treesitter` has no
-- indentexpr, only highlighting/folding). Opt-in per filetype: most useful
-- for languages with embedded/mixed syntax (svelte's html+js+css, astro).
local indentexpr_filetypes = {
  svelte = true,
  astro = true,
}

local function is_markdown(filetype)
  return filetype == "markdown" or filetype:match("^markdown%.") ~= nil
end

local function language_for(bufnr)
  local filetype = vim.bo[bufnr].filetype
  if filetype == "" then
    return nil
  end

  return vim.treesitter.language.get_lang(filetype) or filetype
end

local function load_parser(lang)
  if lang == "scss" then
    local path = vim.api.nvim_get_runtime_file("parser/scss.*", false)[1]
    if path then
      local ok = vim.treesitter.language.add("scss", { path = path })
      if ok then
        return true
      end
    end
  end

  return vim.treesitter.language.add(lang)
end

local function should_enable(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  if vim.bo[bufnr].buftype ~= "" then
    return false
  end

  if vim.b[bufnr].large_file then
    return false
  end

  local filetype = vim.bo[bufnr].filetype
  if filetype == "" or is_markdown(filetype) then
    return false
  end

  if vim.api.nvim_buf_line_count(bufnr) > max_lines then
    return false
  end

  local lang = language_for(bufnr)
  if not lang then
    return false
  end

  local ok = load_parser(lang)
  return ok and lang or false
end

function M.refresh(bufnr)
  local lang = should_enable(bufnr)

  if lang then
    local ok = pcall(vim.treesitter.start, bufnr, lang)
    if ok then
      vim.b[bufnr].treesitter_enabled = true
      if indentexpr_filetypes[vim.bo[bufnr].filetype] then
        vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end
    return
  end

  if vim.b[bufnr].treesitter_enabled then
    pcall(vim.treesitter.stop, bufnr)
    vim.bo[bufnr].syntax = "ON"
    vim.bo[bufnr].indentexpr = ""
    vim.b[bufnr].treesitter_enabled = false
  end
end

function M.setup()
  vim.treesitter.language.register("tsx", { "javascriptreact", "typescriptreact" })
  vim.treesitter.language.register("html", { "htmlangular" })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "FileType", "BufWinEnter" }, {
    desc = "Start Treesitter when allowed",
    callback = function(args)
      M.refresh(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
    desc = "Stop Treesitter when buffer gets too large",
    callback = function(args)
      if vim.b[args.buf].treesitter_enabled and vim.api.nvim_buf_line_count(args.buf) > max_lines then
        M.refresh(args.buf)
      end
    end,
  })
end

return M
