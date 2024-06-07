require'nvim-treesitter.configs'.setup {
  ensure_installed = {"javascript", "typescript", "lua", "markdown", "html", "css"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = { "haskell", "php", "phpdoc" }, -- List of parsers to ignore installing, removed ts from ignore
  autopairs = { enable = true },
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = { "c", "rust", "typescript", "haskell", "markdown", "php" },  -- list of language that will be disabled
  },
  indent = {
    enable = true
  },
 autotag = {
    enable = true,
  },
}
