local M = {}

local options = require("modules.navigation.navigation-options")

M.harpoon = {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  opts = options.harpoon_options,
  keys = options.harpoon_keys,
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
