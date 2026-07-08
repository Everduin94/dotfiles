local util = require("lsp._util")

return {
  init_options = {
    hostInfo = "neovim",
  },
  settings = {
    completions = {
      completeFunctionCalls = true,
    },
  },
  cmd = util.node_command("typescript-language-server"),
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_markers = {
    {
      "tsconfig.json",
      "jsconfig.json",
      "package.json",
      "package-lock.json",
      "pnpm-lock.yaml",
      "yarn.lock",
      "bun.lockb",
      "bun.lock",
    },
    ".git",
  },
}
