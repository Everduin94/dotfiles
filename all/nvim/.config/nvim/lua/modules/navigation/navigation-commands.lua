local M = {}

local util = require("modules.navigation.navigation-util")

vim.api.nvim_create_autocmd({ "SessionLoadPost", "UIEnter" }, {
  callback = util.setup_dynamic_switcher_keymaps,
})

return M
