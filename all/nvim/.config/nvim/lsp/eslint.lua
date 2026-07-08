local util = require("lsp._util")

local eslint_config_files = {
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  ".eslintrc.json",
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
  "eslint.config.mts",
  "eslint.config.cts",
}

local root_markers = {
  {
    "package-lock.json",
    "yarn.lock",
    "pnpm-lock.yaml",
    "bun.lockb",
    "bun.lock",
  },
  ".git",
}

local function has_eslint_config(bufnr, project_root)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return false
  end

  local config = vim.fs.find(eslint_config_files, {
    path = vim.fs.dirname(name),
    upward = true,
    stop = vim.fs.dirname(project_root),
    type = "file",
    limit = 1,
  })[1]

  if config then
    return true
  end

  local package_files = vim.fs.find("package.json", {
    path = vim.fs.dirname(name),
    upward = true,
    stop = vim.fs.dirname(project_root),
    type = "file",
  })

  for _, package_file in ipairs(package_files) do
    local package_json = util.read_json(package_file)
    if package_json and package_json.eslintConfig then
      return true
    end
  end

  return false
end

return {
  cmd = util.node_command("vscode-eslint-language-server"),
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "svelte",
    "htmlangular",
  },
  workspace_required = true,
  root_dir = function(bufnr, on_dir)
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
    if has_eslint_config(bufnr, project_root) then
      on_dir(project_root)
    end
  end,
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "LspEslintFixAll", function()
      client:request_sync("workspace/executeCommand", {
        command = "eslint.applyAllFixes",
        arguments = {
          {
            uri = vim.uri_from_bufnr(bufnr),
            version = vim.lsp.util.buf_versions[bufnr],
          },
        },
      }, 2000, bufnr)
    end, {
      desc = "Apply all ESLint fixes",
    })
  end,
  settings = {
    validate = "on",
    format = false,
    codeActionOnSave = {
      enable = false,
      mode = "all",
    },
    run = "onType",
    workingDirectory = {
      mode = "auto",
    },
    useESLintClass = false,
    experimental = {},
    nodePath = "",
  },
  before_init = function(_, config)
    local root_dir = config.root_dir
    if not root_dir then
      return
    end

    config.settings = config.settings or {}
    config.settings.workspaceFolder = {
      uri = root_dir,
      name = vim.fn.fnamemodify(root_dir, ":t"),
    }
  end,
}
