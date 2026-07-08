local M = {}

function M.setup()
  for _, mode in ipairs({ "n", "i", "x", "o" }) do
    pcall(vim.keymap.del, mode, "<C-j>")
  end

  local tmux = require("config.tmux")
  vim.keymap.set("n", "<C-j>", function()
    tmux.navigate("j", "-D")
  end, { desc = "Window or tmux down" })

  for _, mode in ipairs({ "n", "i", "x", "o" }) do
    vim.keymap.set(mode, "<C-]>", "<Plug>EasyJump", {
      remap = true,
      silent = true,
      desc = "EasyJump",
    })
  end
end

return M
