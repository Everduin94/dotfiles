call plug#begin('~/.config/nvim/autoload/plugged')

    " Base
    " Plug 'jiangmiao/auto-pairs'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'windwp/nvim-autopairs'
    Plug 'akinsho/bufferline.nvim'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'kevinhwang91/rnvimr', {'do': 'make sync'}
    Plug 'norcalli/nvim-colorizer.lua'
    Plug 'junegunn/rainbow_parentheses.vim'
    Plug 'mhinz/vim-startify'
    Plug 'justinmk/vim-sneak'
    Plug 'unblevable/quick-scope'
    Plug 'liuchengxu/vim-which-key'
    Plug 'metakirby5/codi.vim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'
    Plug 'machakann/vim-highlightedyank'
    Plug 'mattn/emmet-vim'
    " Plug 'chamindra/marvim'
    Plug 'voldikss/vim-floaterm'
    Plug 'folke/trouble.nvim'
    " Plug 'Everduin94/nvim-quick-switcher'

    " Debugger
    Plug 'mfussenegger/nvim-dap'
    Plug 'Pocco81/DAPInstall.nvim'
    Plug 'theHamsta/nvim-dap-virtual-text'
    Plug 'nvim-telescope/telescope-dap.nvim'
    Plug 'rcarriga/nvim-dap-ui'
    Plug 'David-Kunz/jester'
    
    " LSP
    Plug 'neovim/nvim-lspconfig'
    Plug 'prettier/vim-prettier', { 'do': 'npm install' }
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-angular'
    
    " Snippets + LSP
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'onsails/lspkind-nvim'
    Plug 'saadparwaiz1/cmp_luasnip'
    Plug 'L3MON4D3/LuaSnip'
    
    " Harpoon
    Plug 'nvim-lua/plenary.nvim' 
    Plug 'nvim-lua/popup.nvim'
    Plug 'ThePrimeagen/harpoon'

    " Telescope
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
    
    " Git Integration
    " Plug 'mhinz/vim-signify'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-rhubarb'
    Plug 'junegunn/gv.vim'
    Plug 'lewis6991/gitsigns.nvim'

    " Markdown Integration
    Plug 'vimwiki/vimwiki'
    Plug 'ferrine/md-img-paste.vim'

    " Theme
    Plug 'shaunsingh/nord.nvim'
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

call plug#end()
