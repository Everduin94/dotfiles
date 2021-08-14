set number

" Don't be vi compatible
set nocompatible

" Helps force plugins to load correctly when it is turned back on below
filetype off

" TODO: Load plugins here
call plug#begin('~/.vim/plugged')

Plug 'victorze/foo'
Plug 'justinmk/vim-sneak'
Plug 'tpope/vim-surround'

call plug#end()

" Syntax highlighting
syntax on

" For plugins to load correctly
filetype plugin indent on

" Last Line
set showmode
set showcmd


" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch

" Searching, not sure what these do
"nnoremap / /\v
"vnoremap / /\va
" Clear search - IDK how to use 07/15/2021
map <leader><space> :let @/=''<cr>
nnoremap H ^
nnoremap L $
nnoremap j k
nnoremap k j
nnoremap J {
nnoremap K }
xnoremap j k
xnoremap k j
xnoremap J {
xnoremap K }
onoremap J {
onoremap K }
onoremap j k
onoremap k j
onoremap H ^
onoremap L $
nnoremap <SPACE> <Nop>
nnoremap <leader>/ :noh<CR>
nnoremap <leader>y yyp
nnoremap <leader>j J
nnoremap <leader>k K
vnoremap K :m '>+1<CR>gv=gv
vnoremap J :m '>-2<CR>gv=gv
inoremap <C-k> <esc>:m .+1<CR>==
inoremap <C-j> <esc>:m .-2<CR>==
nnoremap <leader>j :m .-2<CR>==
nnoremap <leader>k :m .+1<CR>==
map <Space> <Leader>
"nnoremap <expr> j (v:count > 1 ? "m'" . v:count : '') . 'gj'
"nnoremap <expr> k (v:count > 1 ? "m'" . v:count : '') . 'gk'
"nnoremap j v:count j 
" Status Bar
set laststatus=2

" Rendering
set ttyfast

" Allow hidden buffers
set hidden

" Blink cursor on error instead of sound
set visualbell

" Show file states
set ruler
set background=dark

" Pick a leader key
" let mapleader = 
