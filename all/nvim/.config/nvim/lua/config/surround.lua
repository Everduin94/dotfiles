local M = {}

function M.setup()
  require("mini.surround").setup({
    mappings = {
      add = "ys",
      delete = "ds",
      find = "",
      find_left = "",
      highlight = "",
      replace = "cs",
      suffix_last = "",
      suffix_next = "",
    },
    search_method = "cover_or_next",
  })

  vim.keymap.del("x", "ys")
  vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], {
    silent = true,
    desc = "Add surround to selection",
  })
  vim.keymap.set("n", "yss", "ys_", {
    remap = true,
    desc = "Add surround to line",
  })
end

return M
