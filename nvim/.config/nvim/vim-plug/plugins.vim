call plug#begin('~/.config/nvim/autoload/plugged')

    " Better Syntax Support
    " Plug 'sheerun/vim-polyglot'
    " File Explorer
    " Plug 'scrooloose/NERDTree'
    " Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " Plug 'christianchiarulli/nvcode-color-schemes.vim'
    " Auto pairs for '(' '[' '{'
    " Plug 'honza/vim-snippets'
    Plug 'jiangmiao/auto-pairs'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'kevinhwang91/rnvimr', {'do': 'make sync'}
    Plug 'norcalli/nvim-colorizer.lua'
    Plug 'junegunn/rainbow_parentheses.vim'
    Plug 'mhinz/vim-startify'
    Plug 'justinmk/vim-sneak'
    Plug 'unblevable/quick-scope'
    Plug 'liuchengxu/vim-which-key'
    Plug 'metakirby5/codi.vim'
    Plug 'ChristianChiarulli/far.vim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'
    Plug 'machakann/vim-highlightedyank'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    " Plug 'nvim-treesitter/nvim-treesitter-angular'
    Plug 'edkolev/tmuxline.vim'
    Plug 'Konfekt/vim-CtrlXA'
    Plug 'mattn/emmet-vim'
    Plug 'chamindra/marvim'
    Plug 'voldikss/vim-floaterm'
    Plug 'ryanoasis/vim-devicons'
    " LSP
    Plug 'neovim/nvim-lspconfig'
    Plug 'prettier/vim-prettier', { 'do': 'npm install' }
    " Snippets + LSP
    Plug 'hrsh7th/nvim-cmp'
    Plug 'rafamadriz/friendly-snippets'
    " Plug 'hrsh7th/vim-vsnip'
    " Plug 'hrsh7th/vim-vsnip-integ'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'onsails/lspkind-nvim'
    Plug 'saadparwaiz1/cmp_luasnip'
    Plug 'L3MON4D3/LuaSnip'
    
    " Harpoon
    Plug 'nvim-lua/plenary.nvim' 
    Plug 'nvim-lua/popup.nvim'
    Plug 'ThePrimeagen/harpoon'

    " COQ
    
    " main one
    " Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
    " 9000+ Snippets
    " Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}

    " lua & third party sources -- See https://github.com/ms-jpq/coq.thirdparty
    " Need to **configure separately**

    " Plug 'ms-jpq/coq.thirdparty', {'branch': '3p'}



" Sets current working directory to .git root. Messes up monorepo
    " Plug 'airblade/vim-rooter' 

    " Git Integration
    Plug 'mhinz/vim-signify'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-rhubarb'
    Plug 'junegunn/gv.vim'

    " Theme
    " Plug 'romgrk/doom-one.vim'
    " Plug 'joshdick/onedark.vim'
    " Plug 'arcticicestudio/nord-vim' " Keep for airline
    Plug 'shaunsingh/nord.nvim'
    Plug 'tyrannicaltoucan/vim-deep-space'

call plug#end()
