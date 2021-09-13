" enable tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''

" enable powerline fonts
let g:airline_powerline_fonts = 1
let g:airline_left_sep = ''
let g:airline_right_sep = ''

" Disable redundant test in middle
let g:airline_section_c = ''

" Switch to your current theme
let g:airline_theme = 'base16_nord'

" Always show tabs
set showtabline=2

" We don't need to see things like -- INSERT -- anymore
set noshowmode

" NOTE! I switched normal and replace in:
" autoload/plugged/vim-airline-themes/autoload/airline/themes/base16_nord.vim
" If this plugin is reloaded, I'll probably lose that change.

