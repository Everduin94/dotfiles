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
onoremap j k
onoremap k j
onoremap H ^
onoremap L $
nnoremap <SPACE> <Nop>
nnoremap <leader>c ciw
nnoremap <leader>d diw
nnoremap <leader>/ :noh<CR>
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
