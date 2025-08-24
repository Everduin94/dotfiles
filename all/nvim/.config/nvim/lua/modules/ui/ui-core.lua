local M = {}

local ui_options = require("modules.ui.ui-options")
local ui_util = require("modules.ui.ui-util")

M.theme = {
  "rose-pine/neovim",
  name = "rose-pine",
  lazy = false,
  priority = 1000,
  config = function()
    require("rose-pine").setup(ui_options.rose_pine_options)
    vim.cmd("colorscheme rose-pine-moon")
    require("modules.ui.ui-commands")
  end,
}

M.incline = {
  "b0o/incline.nvim",
  config = function()
    require("incline").setup({
      render = ui_util.incline_hide_on_zen_mode,
    })
  end,
  event = "VeryLazy",
}

M.lualine = {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end
    require("modules.sub_mode.sub_mode-commands")
  end,
  opts = ui_options.lualine_options,
}

M.noice = {
  "folke/noice.nvim",
  opts = {
    presets = {
      lsp_doc_border = true,
    },
  },
}

M.treesitter = {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    indent = { enable = true },
    ensure_installed = ui_options.treesitter_ensure_installed,
  },
}

M.markview = {
  "OXY2DEV/markview.nvim",
  lazy = false,
  opts = {
    preview = {
      filetypes = { "markdown", "codecompanion" },
      hybrid_modes = { "n" },
      ignore_buftypes = {},
    },
    markdown = {
      list_items = ui_options.markview_list_items_options,
    },
  },
  priority = 49,
}

return M
