local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- General
  use "wbthomason/packer.nvim" -- Have packer manage itself
  use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
  use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins
  use "windwp/nvim-autopairs" -- Autopairs, integrates with both cmp and treesitter
  use "LunarVim/bigfile.nvim"
  use "folke/flash.nvim"
  use "SUSTech-data/wildfire.nvim"

  -- use "akinsho/bufferline.nvim"
  use "nvim-lualine/lualine.nvim"
  use "kyazdani42/nvim-web-devicons"
  use "folke/which-key.nvim"
  use "norcalli/nvim-colorizer.lua"
  -- Maybe replace with FTerm?
  -- use "akinsho/toggleterm.nvim"
  use "metakirby5/codi.vim"
  use "kylechui/nvim-surround"
  use "numToStr/Comment.nvim" -- Easily comment stuff
  use "lewis6991/impatient.nvim" -- load lua modules faster 
  use {"Everduin94/nvim-quick-switcher"}
  use "roobert/tailwindcss-colorizer-cmp.nvim"

  -- use "tpope/vim-commentary"
  -- use "machakann/vim-highlightedyank"
  use "mattn/emmet-vim"
  use "ThePrimeagen/harpoon"
  use "lukas-reineke/indent-blankline.nvim"
  use "Pocco81/true-zen.nvim"
  use "folke/twilight.nvim"
  -- DATABASE
  use "tpope/vim-dadbod"
  use "kristijanhusak/vim-dadbod-ui"
  use "kristijanhusak/vim-dadbod-completion"


  -- CMP
  use "hrsh7th/nvim-cmp"  -- completion
  use "hrsh7th/cmp-buffer" -- buffer completions
  use "hrsh7th/cmp-path" -- path completions
  use "hrsh7th/cmp-cmdline" -- cmdline completions
  use "saadparwaiz1/cmp_luasnip" -- snippet completions
  use "hrsh7th/cmp-nvim-lsp"

  -- LSP
  use "neovim/nvim-lspconfig" -- enable LSP
  use "williamboman/nvim-lsp-installer" -- simple to use language server installer
  use "onsails/lspkind-nvim"

  use "jose-elias-alvarez/null-ls.nvim" -- for formatters and linters
  -- "WhoIsSethDaniel/mason-tool-installer.nvim",
  -- "jay-babu/mason-null-ls.nvim",
  use "jose-elias-alvarez/typescript.nvim"
  -- use "williamboman/mason.nvim"

  -- Snippets
  use "L3MON4D3/LuaSnip"
  -- Colorschemes
  -- use "folke/tokyonight.nvim"
  use { "catppuccin/nvim", as = "catppuccin" }
  -- Telescope
  use "nvim-telescope/telescope.nvim"
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
  use "benfowler/telescope-luasnip.nvim"
  -- use {'nvim-telescope/telescope-fzy-native.nvim', run = 'make' }
  use "nvim-telescope/telescope-ui-select.nvim"
  -- File Tree
  use {"kyazdani42/nvim-tree.lua", commit = "f3b7372"}
  -- Treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  }
  use "nvim-treesitter/playground"
  use "windwp/nvim-ts-autotag"

  -- use "nvim-treesitter/nvim-treesitter-angular"
  -- use "JoosepAlviste/nvim-ts-context-commentstring"
  -- Git
  use "lewis6991/gitsigns.nvim"
  use "tpope/vim-fugitive"
    -- Github
  -- use {
  --   'pwntester/octo.nvim',
  --     requires = {
  --       'nvim-lua/plenary.nvim',
  --       'nvim-telescope/telescope.nvim',
  --       'kyazdani42/nvim-web-devicons',
  --     },
  -- }
  -- Debugger
  use "mfussenegger/nvim-dap"
  use "Pocco81/DAPInstall.nvim"
  use "theHamsta/nvim-dap-virtual-text"
  use "nvim-telescope/telescope-dap.nvim"
  use "rcarriga/nvim-dap-ui"
  -- Wiki
  use "vimwiki/vimwiki"
  use "ferrine/md-img-paste.vim"
  -- Dashboard
  use {'goolord/alpha-nvim', requires = { 'kyazdani42/nvim-web-devicons' }}


  -- Interested in or may use in future
    -- use "moll/vim-bbye"
    -- use "ahmedkhalf/project.nvim"
    -- use "antoinemadec/FixCursorHold.nvim" -- This is needed to fix lsp doc highlight
    -- use "tamago324/nlsp-settings.nvim" -- language server settings defined in json for

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
