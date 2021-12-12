lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = { "haskell" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = { "c", "rust", "haskell", "typescript"},  -- list of language that will be disabled
  },
}
-- TODO: Can we enable typescript treesitter, angular html, but disable angular typescript?
EOF
