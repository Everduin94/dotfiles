local M = {}

local options = require("modules.navigation.navigation-options")

M.harpoon = {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  opts = options.harpoon_options,
  keys = options.harpoon_keys,
}
M.grapple = {
  "cbochs/grapple.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons", lazy = true },
  },
  keys = options.grapple_keys,
  opts = {
    name_pos = "start",
    style = "basename",
  },
}
M.surround = {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({})
  end,
}
M.quick_switcher = {
  "Everduin94/nvim-quick-switcher",
  init = function()
    print("nvim quick switcher init")
    require("modules.navigation.navigation-commands")
  end,
}

return M
