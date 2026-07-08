local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.numberwidth = 4
opt.cursorline = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.infercase = true
opt.incsearch = true
opt.hlsearch = false
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"
opt.wrap = false
opt.linebreak = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.updatetime = 200
opt.timeoutlen = 300
opt.confirm = true
opt.undofile = true
opt.completeopt = { "menu", "menuone", "noselect", "popup" }
opt.pumheight = 12
opt.virtualedit = "block"
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.formatoptions = "qjl1"
opt.foldmethod = "manual"
opt.fillchars = { eob = " " }
opt.shortmess:append("WcC")
opt.iskeyword:append("-")
