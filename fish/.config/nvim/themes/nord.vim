colorscheme nord
hi Normal guibg=NONE ctermbg=NONE           " Transparent background
highlight clear SignColumn
highlight SignColumn ctermbg=NONE cterm=NONE guibg=NONE gui=NONE
highlight SignifySignAdd guibg=NONE guifg=#A3BE8C cterm=NONE gui=NONE
highlight SignifySignDelete guibg=NONE guifg=#BF616A cterm=NONE gui=NONE
highlight SignifySignChange guibg=NONE guifg=#EBCB8B cterm=NONE gui=NONE
highlight Sneak guifg=#2E3440 guibg=#f1fa8c	 ctermfg=black ctermbg=cyan
" highlight SneakScope guifg=red guibg=yellow ctermfg=red ctermbg=yellow
highlight SneakScope guifg=#2E3440 guibg=#ECEFF4 
hi FloatermBorder guibg=none guifg=#3EB489

" This probably doesn't hurt to have but may not be needed.
" always show the signcolumn
autocmd BufRead,BufNewFile * setlocal signcolumn=yes
" remove the color from the signColumn
autocmd BufRead,BufNewFile * highlight clear SignColumn

" I changed these from #A3BE8C to #3EB489
" autoload/plugged/nord.nvim/lua/nord/colors.lua
" autoload/plugged/vim-airline-themes/autoload/airline/themes/base16_nord.vim
"
" I changed these as well -- Removed quoted for syntax -- ! Only in airline
" let s:gui01 = #041c33     
" let s:gui02 = #02152e     
