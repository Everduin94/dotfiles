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
nnoremap / /\v
vnoremap / /\v
" Clear search - IDK how to use 07/15/2021
map <leader><space> :let @/=''<cr>

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
