local util = require("lsp._util")

return {
  cmd = util.node_command("svelteserver"),
  filetypes = { "svelte" },
  root_markers = {
    {
      "svelte.config.js",
      "svelte.config.cjs",
      "svelte.config.mjs",
      "svelte.config.ts",
      "package.json",
    },
    ".git",
  },
  on_attach = function(client)
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.js", "*.ts" },
      group = vim.api.nvim_create_augroup("native-lsp-svelte", { clear = true }),
      callback = function(args)
        client:notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_fname(args.match) })
      end,
    })
  end,
}
