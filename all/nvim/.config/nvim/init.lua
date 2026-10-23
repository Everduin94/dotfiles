local inline = vim.env.PI_NVIM_INLINE == "1"

vim.g.pi_nvim_inline = inline
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.options")
require("config.autocmds")
require("config.keymaps")
require("config.submode").setup()

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = true,
  float = { border = "rounded" },
})

local plugins = {
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  { src = "https://github.com/rebelot/kanagawa.nvim", name = "kanagawa" },
  { src = "https://github.com/folke/tokyonight.nvim" },
  { src = "https://github.com/EdenEast/nightfox.nvim" },
  { src = "https://github.com/nvim-mini/mini.completion" },
  { src = "https://github.com/nvim-mini/mini.snippets" },
  { src = "https://github.com/nvim-mini/mini.pairs" },
  { src = "https://github.com/nvim-mini/mini.jump2d" },
  { src = "https://github.com/nvim-mini/mini.surround" },
  { src = "https://github.com/nvim-mini/mini.clue" },
  { src = "https://github.com/nvim-mini/mini.bufremove" },
  { src = "https://github.com/nvim-mini/mini.statusline" },
  { src = "https://github.com/nvim-mini/mini.cursorword" },
  { src = "https://github.com/nvim-mini/mini.hipatterns" },
  { src = "https://github.com/nvim-mini/mini.indentscope" },
}

if not inline then
  vim.list_extend(plugins, {
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/cbochs/grapple.nvim", name = "grapple.nvim" },
    { src = "https://github.com/nvim-mini/mini.diff" },
    { src = "https://github.com/nvim-mini/mini.sessions" },
    { src = "https://github.com/folke/snacks.nvim" },
    { src = "https://github.com/nvim-neotest/neotest" },
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    { src = "https://codeberg.org/ziglang/zig.vim" },
    { src = "https://github.com/nvim-mini/mini.animate" },
    { src = "https://github.com/olimorris/codecompanion.nvim", version = vim.version.range("^20.0.0") },
    { src = "https://github.com/OXY2DEV/markview.nvim", version = vim.version.range("^29.0.0") },
  })
end

vim.pack.add(plugins, {
  confirm = false,
  load = true,
})

require("config.colors")
require("config.statusline").setup()
require("mini.cursorword").setup()
require("config.indentscope").setup()

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

require("config.pairs").setup()
require("config.jump").setup()
require("config.surround").setup()
require("config.snippets").setup()
require("config.completion").setup()

if not inline then
  require("config.lsp")
  require("config.format").setup()
  require("config.treesitter").setup()
  require("config.grapple")
  require("config.diff").setup()
  require("config.pick").setup()
  require("config.sessions").setup()
  require("config.test").setup()

  require("config.oil").setup()
  require("config.ai").setup()
  require("config.markview").setup()
  require("config.panels").setup()

  local animate = require("mini.animate")
  local quick = animate.gen_timing.linear({ duration = 120, unit = "total" })
  animate.setup({
    cursor = { timing = quick },
    scroll = { timing = quick },
    resize = { timing = quick },
    open = { timing = quick },
    close = { timing = quick },
  })
end

require("config.clue").setup()

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "Update vim.pack plugins" })
