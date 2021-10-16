let g:floaterm_keymap_toggle = '<F1>'
let g:floaterm_keymap_next   = '<F2>'
let g:floaterm_keymap_prev   = '<F3>'
let g:floaterm_keymap_new    = '<F4>'

" Floaterm
let g:floaterm_gitcommit='floaterm'
let g:floaterm_autoinsert=1
let g:floaterm_width=0.8
let g:floaterm_height=0.8
let g:floaterm_wintitle=0
let g:floaterm_autoclose=1
let g:floaterm_shell='fish'


nmap <leader>t; :FloatermNew! --title=SYSTEM-ONLINE cd %:p:h <CR>
nmap <leader>tr :FloatermNew! --title=風 cd %:p:h \| nvim -c Codi temp.js<CR>

