" configure treesitter
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = { "haskell" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = { "c", "rust", "haskell"},  -- list of language that will be disabled
  },
}
EOF

" configure nvcode-color-schemes
" let g:nvcode_termcolors=256

" syntax on
colorscheme nord " Or whatever colorscheme you make


" checks if your terminal has 24-bit color support
if (has("termguicolors"))
 "   set termguicolors
 "   hi LineNr ctermbg=NONE guibg=NONE
endif
