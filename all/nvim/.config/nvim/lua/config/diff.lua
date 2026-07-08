local M = {}

function M.setup()
  require("mini.diff").setup({
    view = {
      style = "sign",
      signs = {
        add = "│",
        change = "│",
        delete = "│",
      },
    },
  })
end

return M
