local M = {}

local function read_char(prompt)
  vim.cmd.redraw()
  vim.api.nvim_echo({ { prompt, "Question" } }, false, {})

  local ok, char = pcall(vim.fn.getcharstr)
  if not ok or char == nil or char == "" then
    return nil
  end

  if char == vim.keycode("<Esc>") or char == vim.keycode("<C-c>") then
    return nil
  end

  return char
end

function M.jump_two_chars()
  local first = read_char("Jump 1/2: ")
  if first == nil then
    return
  end

  local second = read_char(string.format("Jump 2/2: %s", first))
  if second == nil then
    return
  end

  local pattern = vim.pesc(first .. second)

  MiniJump2d.start({
    spotter = MiniJump2d.gen_spotter.pattern(pattern),
    allowed_lines = {
      blank = false,
      fold = false,
    },
  })
end

function M.setup()
  require("mini.jump2d").setup({
    mappings = {
      start_jumping = "",
    },
    view = {
      dim = true,
      n_steps_ahead = 1,
    },
    allowed_windows = {
      current = true,
      not_current = false,
    },
  })

  vim.keymap.set({ "n", "x", "o" }, "s", M.jump_two_chars, { desc = "Jump to 2-char match" })
end

return M
