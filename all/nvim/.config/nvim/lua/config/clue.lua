local M = {}

local function leader_clues()
  local clues = {
    { mode = { "n", "x" }, keys = "<Leader>a", desc = "+ai" },
    { mode = "n", keys = "<Leader>m", desc = "+snippets" },
    { mode = "n", keys = "<Leader>o", desc = "+open" },
    { mode = "n", keys = "<Leader>p", desc = "+path" },
    { mode = "n", keys = "<Leader>q", desc = "+quit" },
    { mode = "n", keys = "<Leader>s", desc = "+session" },
    { mode = { "n", "x" }, keys = "<Leader>t", desc = "+terminal" },
    { mode = "n", keys = "<Leader>u", desc = "+ui" },
    { mode = "n", keys = "<Leader>w", desc = "+window" },
  }

  if not vim.g.pi_nvim_inline then
    vim.list_extend(clues, {
      { mode = "n", keys = "<Leader>c", desc = "+code" },
      { mode = "n", keys = "<Leader>g", desc = "+git" },
      { mode = "n", keys = "<Leader>r", desc = "+run tests" },
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

  -- mini.clue skips unlisted buffers like the chat, which leaves <leader>
  -- on the 300ms timeout.
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("config_clue_special", { clear = true }),
    pattern = { "codecompanion" },
    callback = function(args)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          MiniClue.ensure_buf_triggers(args.buf)
        end
      end)
    end,
  })
end

return M
