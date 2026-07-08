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
  { src = "https://github.com/roy2220/easyjump.tmux" },
}

if not inline then
  vim.list_extend(plugins, {
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/cbochs/grapple.nvim", name = "grapple.nvim" },
    { src = "https://github.com/nvim-mini/mini.diff" },
    { src = "https://github.com/folke/snacks.nvim" },
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
require("config.easyjump").setup()
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

  require("oil").setup({
    default_file_explorer = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
      show_hidden = true,
      natural_order = true,
    },
  })
end

require("config.clue").setup()

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "Update vim.pack plugins" })
