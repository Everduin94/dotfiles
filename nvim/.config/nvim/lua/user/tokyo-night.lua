vim.g.tokyonight_colors = {
  green = '#6ace95'
}

-- Transparent
vim.g.tokyonight_transparent = 1
vim.g.tokyonight_transparent_sidebar = true

-- Normal - (see utility.lua)
-- vim.g.tokyonight_dark_sidebar = true
-- vim.g.tokyonight_sidebars = {"packer", "NvimTree", "which-key", "dap-repl", "dapui_watches",  "dapui_scopes", "dapui_stacks", "terminal", "qf"}

vim.cmd [[
  colorscheme tokyonight
  set bg=dark
]]

