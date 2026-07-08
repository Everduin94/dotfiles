local util = require("lsp._util")

local M = {}

local prettier_filetypes = {
  css = true,
  html = true,
  htmlangular = true,
  javascript = true,
  javascriptreact = true,
  json = true,
  jsonc = true,
  less = true,
  markdown = true,
  ["markdown.mdx"] = true,
  scss = true,
  svelte = true,
  typescript = true,
  typescriptreact = true,
  yaml = true,
}

local eslint_filetypes = {
  htmlangular = true,
  javascript = true,
  javascriptreact = true,
  svelte = true,
  typescript = true,
  typescriptreact = true,
}

local prettier_root_markers = {
  {
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.json5",
    ".prettierrc.yml",
    ".prettierrc.yaml",
    ".prettierrc.js",
    ".prettierrc.cjs",
    ".prettierrc.mjs",
    "prettier.config.js",
    "prettier.config.cjs",
    "prettier.config.mjs",
    "prettier.config.ts",
    "prettier.config.mts",
    "prettier.config.cts",
  },
  {
    ".editorconfig",
    "package.json",
    "package-lock.json",
    "pnpm-lock.yaml",
    "yarn.lock",
    "bun.lock",
    "bun.lockb",
    "nx.json",
  },
  ".git",
}

local function get_buffer_text(bufnr)
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
end

local function set_buffer_text(bufnr, text)
  local view = vim.fn.winsaveview()
  local lines = vim.split(text, "\n", { plain = true, trimempty = false })

  if #lines > 0 and lines[#lines] == "" then
    table.remove(lines, #lines)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.fn.winrestview(view)
end

local function find_prettier_root(bufnr)
  local root = vim.fs.root(bufnr, prettier_root_markers)
  if root then
    return root
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= "" then
    return vim.fs.dirname(name)
  end

  return vim.fn.getcwd()
end

local function prettier_command(root_dir, file_name)
  local prettierd = util.prefer_local_executable(root_dir, "prettierd")
  if vim.fn.executable(prettierd) == 1 then
    return { prettierd, file_name }
  end

  local prettier = util.prefer_local_executable(root_dir, "prettier")
  if vim.fn.executable(prettier) == 1 then
    return { prettier, "--stdin-filepath", file_name }
  end
end

local function apply_eslint_fixes(bufnr)
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" })[1]
  if not client then
    return
  end

  client:request_sync("workspace/executeCommand", {
    command = "eslint.applyAllFixes",
    arguments = {
      {
        uri = vim.uri_from_bufnr(bufnr),
        version = vim.lsp.util.buf_versions[bufnr],
      },
    },
  }, 2000, bufnr)
end

local function run_prettier(bufnr)
  local file_name = vim.api.nvim_buf_get_name(bufnr)
  if file_name == "" then
    return
  end

  local root_dir = find_prettier_root(bufnr)
  local cmd = prettier_command(root_dir, file_name)
  if not cmd then
    vim.notify_once("Prettier not found in node_modules/.bin or $PATH", vim.log.levels.WARN)
    return
  end

  local input = get_buffer_text(bufnr)
  local result = vim.system(cmd, {
    cwd = root_dir,
    stdin = input,
    text = true,
  }):wait(5000)

  if result.code ~= 0 then
    local err = (result.stderr or result.stdout or ""):gsub("%s+$", "")
    if err ~= "" then
      vim.notify(err, vim.log.levels.WARN)
    end
    return
  end

  local output = result.stdout or ""
  if output ~= input then
    set_buffer_text(bufnr, output)
  end
end

function M.format_on_save(args)
  local bufnr = args.buf
  local filetype = vim.bo[bufnr].filetype

  if vim.b[bufnr].large_file then
    return
  end

  if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable then
    return
  end

  if eslint_filetypes[filetype] then
    apply_eslint_fixes(bufnr)
  end

  if prettier_filetypes[filetype] then
    run_prettier(bufnr)
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "Run ESLint fixes and Prettier on save",
    callback = M.format_on_save,
  })
end

return M
