"   /  _/ | / /  _/_  __/ |  / /  _/  |/  /
"   / //  |/ // /  / /  | | / // // /|_/ / 
" _/ // /|  // /  / /  _| |/ // // /  / /  
"/___/_/ |_/___/ /_/  (_)___/___/_/  /_/   
"

" Vim Plugins 
source $HOME/.config/nvim/vim-plug/plugins.vim
source $HOME/.config/nvim/general/settings.vim
source $HOME/.config/nvim/keys/mappings.vim
source $HOME/.config/nvim/plug-config/rnvimr.vim
source $HOME/.config/nvim/plug-config/rainbow.vim
source $HOME/.config/nvim/plug-config/start-screen.vim
source $HOME/.config/nvim/plug-config/sneak.vim
source $HOME/.config/nvim/plug-config/quickscope.vim
source $HOME/.config/nvim/plug-config/which-key.vim
source $HOME/.config/nvim/plug-config/codi.vim
source $HOME/.config/nvim/plug-config/fzf.vim 
source $HOME/.config/nvim/plug-config/treesitter.vim
source $HOME/.config/nvim/plug-config/emmet.vim
source $HOME/.config/nvim/plug-config/marvim.vim
source $HOME/.config/nvim/plug-config/floaterm.vim
source $HOME/.config/nvim/plug-config/prettier.vim
source $HOME/.config/nvim/plug-config/harpoon.vim
source $HOME/.config/nvim/plug-config/lsp-config.vim
source $HOME/.config/nvim/plug-config/vim-wiki.vim
source $HOME/.config/nvim/plug-config/opposite-day.vim

" Lua Plugins
luafile $HOME/.config/nvim/lua/keymaps-config.lua
luafile $HOME/.config/nvim/lua/compe-config.lua
luafile $HOME/.config/nvim/lua/plug-colorizer.lua
luafile $HOME/.config/nvim/lua/lualine-config.lua
luafile $HOME/.config/nvim/lua/bufferline-config.lua
luafile $HOME/.config/nvim/lua/lsp/typescript-ls.lua
luafile $HOME/.config/nvim/lua/lsp/angular-ls.lua
luafile $HOME/.config/nvim/lua/lsp/html-ls.lua
luafile $HOME/.config/nvim/lua/lsp/lua-ls.lua
luafile $HOME/.config/nvim/lua/lsp/efm-ls.lua
luafile $HOME/.config/nvim/lua/harpoon-setup.lua
luafile $HOME/.config/nvim/lua/trouble-config.lua
luafile $HOME/.config/nvim/lua/switcher-config.lua
luafile $HOME/.config/nvim/lua/luasnip-config.lua
luafile $HOME/.config/nvim/lua/telescope-config.lua
luafile $HOME/.config/nvim/lua/nvim-dap-config.lua
luafile $HOME/.config/nvim/lua/autopairs-config.lua
luafile $HOME/.config/nvim/lua/gitsigns-config.lua

" Theme
source $HOME/.config/nvim/themes/tokyo-night.vim

" Autocmd
autocmd BufWritePost /Users/everduin/dotfiles/tmux/.config/tmux/tmux.conf execute ':!tmux source-file %' 
