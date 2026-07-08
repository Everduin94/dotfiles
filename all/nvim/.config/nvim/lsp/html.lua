local util = require("lsp._util")

return {
  cmd = util.node_command("vscode-html-language-server"),
  filetypes = { "html" },
  root_markers = { "package.json", ".git" },
  init_options = {
    provideFormatter = true,
    embeddedLanguages = {
      css = true,
      javascript = true,
    },
    configurationSection = { "html", "css", "javascript" },
  },
  settings = {},
}
