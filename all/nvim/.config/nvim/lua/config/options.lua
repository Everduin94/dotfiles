local opt = vim.opt
opt.pumblend = 0 -- Popup blend
opt.showtabline = 0
vim.cmd([[set iskeyword+=-]])
vim.g.root_spec = { "cwd" } -- HOLYYYYYYYYYY WHY IS THIS NOT THE DEFAULT
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.smarttab = true
