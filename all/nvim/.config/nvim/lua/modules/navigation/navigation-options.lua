local M = {}

local util = require("modules.navigation.navigation-util")

M.harpoon_options = {
  menu = {
    width = vim.api.nvim_win_get_width(0) - 4,
  },
  settings = {
    save_on_toggle = true,
    sync_on_ui_close = true,
    key = function()
      print("Harpoon key: ", vim.fn.getcwd())
      return vim.fn.getcwd()
    end,
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

M.grapple_keys = function()
  local keys = {
    {
      "<leader>0",
      function()
        require("grapple").tag()
      end,
      desc = "Grapple File",
    },
    {
      "<leader>h",
      function()
        local grapple = require("grapple")
        grapple.toggle_tags()
      end,
      desc = "Grapple Quick Menu",
    },
    {
      "<leader>H",
      function()
        local grapple = require("grapple")
        grapple.reset()
      end,
      desc = "Grapple Reset",
    },
  }

  for i = 1, 5 do
    table.insert(keys, {
      "<leader>" .. i,
      function()
        require("grapple").select({ index = i })
      end,
      desc = "Grapple to File " .. i,
    })
  end
  return keys
end

-- Still use for terminal
M.harpoon_keys = function()
  local keys = {}
  return keys
end

return M
