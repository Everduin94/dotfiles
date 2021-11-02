" Map leader to which_key
nnoremap <silent> <leader> :silent WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :silent <c-u> :silent WhichKeyVisual '<Space>'<CR>

" Create map to add keys to
let g:which_key_map =  {}
" Define a separator
let g:which_key_sep = '→'
" set timeoutlen=100


" Not a fan of floating windows for this
let g:which_key_use_floating_win = 0

" Change the colors if you want
highlight default link WhichKey          Operator
highlight default link WhichKeySeperator DiffAdded
highlight default link WhichKeyGroup     Identifier
highlight default link WhichKeyDesc      Function

" Hide status line
autocmd! FileType which_key
autocmd  FileType which_key set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler

" Single mappings
let g:which_key_map['r'] = [ ':Ranger' , 'ranger' ]
" Number Binds
let g:which_key_map['0'] = 'Harpoon Add'
let g:which_key_map['1'] = 'Harpoon 1'
let g:which_key_map['2'] = 'Harpoon 2'
let g:which_key_map['3'] = 'Harpoon 3'
let g:which_key_map['4'] = 'Harpoon 4'
let g:which_key_map['e'] = 'Harpoon Menu'
let g:which_key_map['j'] = 'Join line'
let g:which_key_map['q'] = 'Save->close'
let g:which_key_map['k'] = 'Man page'

" Angular Switcher
let g:which_key_map.o = {
    \ 'name' : '+Switcher' ,
    \ 'o' : 'HTML',
    \ 'i' : 'CSS',
    \ 'u' : 'TS',
    \ 'y' : 'Spec',
    \ }

let g:which_key_map.t = {
    \ 'name' : '+Flo' ,
    \ ';' : 'Shell',
    \ 'r' : 'Codi',
    \ '1' : 'Terminal-1',
    \ '2' : 'Terminal-2',
    \ 'c' : 'Cmd Menu',
    \ }


let g:which_key_map.g = {
    \ 'name' : '+Git' ,
    \ 'k' : 'Next Hunk' ,
    \ 'j' : 'Prev Hunk' ,
    \ 'f' : 'Fugitive' ,
    \ '1' : 'Take Left' ,
    \ '2' : 'Take Right' ,
    \ 'b' : [':Git blame', 'Blame'],
    \ 'l' : [':Git log', 'Log'],
    \ 'v' : [':Gvdiffsplit', 'Diff Split'],
    \ 'w' : [':Git difftool', 'Diff Tool'],
    \ 'e' : [':Git mergetool', 'Merge Tool'],
    \ }

let g:which_key_map.g.c = {
    \ 'name' : '+Workflow' ,
    \ }

let g:which_key_map.R = {
    \ 'name' : '+Macros' ,
    \ }

let g:which_key_map.p = {
    \ 'name' : '+Search' ,
    \ }

" f is for FAR
let g:which_key_map.f = {
    \ 'name' : '+Far' ,
    \ 'b' : [':Farr --source=vimgrep'    , 'buffer'],
    \ 'p' : [':Farr --source=rgnvim'     , 'project'],
    \ }

" Vim Splits
let g:which_key_map.v = {
    \ 'name' : '+Splits' ,
    \ 'k' : [':15sp'    , 'Down'],
    \ 'l' : [':65vsp'     , 'Right'],
    \ 'c' : [':close'     , 'Close'],
    \ ']' : [':vertical resize +5'     , '+->'],
    \ '[' : [':vertical resize -5'     , '<-+'],
    \ '=' : [':resize +5'     , 'vvv'],
    \ '-' : [':resize -5'     , '^^^'],
    \ '\' : ['<C-W>='     , 'Balance'],
    \ '|' : ['<C-W>|'     , 'Hide'],
    \ }

" Register which key map
call which_key#register('<Space>', "g:which_key_map")

