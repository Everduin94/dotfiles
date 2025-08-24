local M = {}

local util = require("modules.navigation.navigation-util")

M.harpoon_options = {
  menu = {
    width = vim.api.nvim_win_get_width(0) - 4,
  },
  settings = {
    save_on_toggle = true,
    sync_on_ui_close = true,
  },

  default = {
    select_with_nil = true,
    encode = false,
  },
  term = {
    select_with_nil = true,
    encode = false,
    select = util.term,
  },
}

M.harpoon_keys = function()
  local keys = {
    {
      "<leader>0",
      function()
        require("harpoon"):list():add()
      end,
      desc = "Harpoon File",
    },
    {
      "<leader>h",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "Harpoon Quick Menu",
    },
  }

  for i = 1, 5 do
    table.insert(keys, {
      "<leader>" .. i,
      function()
        require("harpoon"):list():select(i)
      end,
      desc = "Harpoon to File " .. i,
    })
  end
  return keys
end

return M
