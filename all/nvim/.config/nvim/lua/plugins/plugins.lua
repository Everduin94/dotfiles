local ai_core = require("modules.ai.ai-core")
local ui_core = require("modules.ui.ui-core")
local navigation_core = require("modules.navigation.navigation-core")
local completion_core = require("modules.completion.completion-core")
local test_core = require("modules/test/test-core")
local ls_core = require("modules/language_servers/language_servers-core")
local util_core = require("modules.util.util-core")
local snippets_core = require("modules.snippets.snippets-core")

return {
  ai_core.mcphub,
  ai_core.codecompanion,
  ai_core.img_clip,
  ui_core.theme,
  ui_core.incline,
  ui_core.lualine,
  ui_core.noice,
  ui_core.treesitter,
  ui_core.markview,
  navigation_core.harpoon,
  navigation_core.quick_switcher,
  navigation_core.surround,
  completion_core.blink,
  test_core.neotest,
  ls_core.lsp_config,
  util_core.autopair,
  util_core.autolist,
  snippets_core.luasnip,
  { "akinsho/bufferline.nvim", enabled = false },
  { "folke/edgy.nvim", enabled = false },
  { "RRethy/vim-illuminate", enabled = false },
  { "HiPhish/rainbow-delimiters.nvim", enabled = false },
  { "echasnovski/mini.pairs", enabled = false },
}
