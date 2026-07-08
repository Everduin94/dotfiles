local util = require("lsp._util")

local root_markers = {
  "tailwind.config.js",
  "tailwind.config.cjs",
  "tailwind.config.mjs",
  "tailwind.config.ts",
  "postcss.config.js",
  "postcss.config.cjs",
  "postcss.config.mjs",
  "postcss.config.ts",
}

return {
  cmd = util.node_command("tailwindcss-language-server"),
  filetypes = {
    "html",
    "htmlangular",
    "css",
    "scss",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "svelte",
  },
  workspace_required = true,
  before_init = function(_, config)
    config.settings = vim.tbl_deep_extend("keep", config.settings or {}, {
      editor = {
        tabSize = vim.lsp.util.get_effective_tabstop(),
      },
    })
  end,
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, root_markers)
    if root then
      on_dir(root)
      return
    end

    local package_root = util.find_package_with_dependency(bufnr, "tailwindcss")
    if package_root then
      on_dir(package_root)
    end
  end,
  settings = {
    tailwindCSS = {
      validate = true,
      classAttributes = {
        "class",
        "className",
        "class:list",
        "classList",
        "ngClass",
      },
      includeLanguages = {
        htmlangular = "html",
      },
      lint = {
        cssConflict = "warning",
        invalidApply = "error",
        invalidScreen = "error",
        invalidVariant = "error",
        invalidConfigPath = "error",
        invalidTailwindDirective = "error",
        recommendedVariantOrder = "warning",
      },
    },
  },
}
