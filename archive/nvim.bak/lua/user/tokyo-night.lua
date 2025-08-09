vim.g.tokyonight_colors = {
  green = '#6ace95'
}

-- Transparent Code (Add opacity to alacrity)
-- vim.g.tokyonight_transparent = 1

-- All transparent
-- vim.g.tokyonight_transparent = 1
-- vim.g.tokyonight_transparent_sidebar = true

-- Normal - (see utility.lua)
vim.g.tokyonight_dark_sidebar = true
vim.g.tokyonight_sidebars = {"packer", "toggleterm", "NvimTree", "which-key", "dap-repl", "dapui_watches",  "dapui_scopes", "dapui_stacks", "terminal", "qf"}

-- Really Dark
vim.g.tokyonight_style = "night"
-- You need to change the tmux color

-- Default
-- vim.g.tokyonight_style = "storm"

vim.cmd [[
  colorscheme tokyonight
  set bg=dark
]]

