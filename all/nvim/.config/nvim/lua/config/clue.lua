local M = {}

local function leader_clues()
  local clues = {
    { mode = { "n", "x" }, keys = "<Leader>a", desc = "+pi" },
    { mode = "n", keys = "<Leader>m", desc = "+snippets" },
    { mode = "n", keys = "<Leader>q", desc = "+quit" },
    { mode = "n", keys = "<Leader>t", desc = "+tmux" },
    { mode = "n", keys = "<Leader>w", desc = "+write" },
  }

  if not vim.g.pi_nvim_inline then
    vim.list_extend(clues, {
      { mode = "n", keys = "<Leader>c", desc = "+code" },
      { mode = "n", keys = "<Leader>g", desc = "+git" },
    })
  end

  return clues
end

function M.setup()
  local miniclue = require("mini.clue")
  local clues = leader_clues()

  vim.list_extend(clues, miniclue.gen_clues.square_brackets())
  vim.list_extend(clues, miniclue.gen_clues.g())
  vim.list_extend(clues, miniclue.gen_clues.windows())
  vim.list_extend(clues, miniclue.gen_clues.z())

  miniclue.setup({
    triggers = {
      { mode = { "n", "x" }, keys = "<Leader>" },
      { mode = { "n", "x" }, keys = "g" },
      { mode = "n", keys = "[" },
      { mode = "n", keys = "]" },
      { mode = "n", keys = "<C-w>" },
      { mode = { "n", "x" }, keys = "z" },
    },
    clues = clues,
    window = {
      delay = 200,
      config = {
        border = "rounded",
      },
    },
  })
end

return M
