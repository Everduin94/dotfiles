local M = {}

local function picker_cwd()
  local start = vim.api.nvim_buf_get_name(0)
  if start == "" then
    start = vim.fn.getcwd()
  else
    start = vim.fs.dirname(start)
  end

  local git_dir = vim.fs.find(".git", { path = start, upward = true })[1]
  if git_dir then
    return vim.fs.dirname(git_dir)
  end

  return vim.fn.getcwd()
end

function M.files()
  Snacks.picker.smart({
    cwd = picker_cwd(),
  })
end

function M.grep()
  Snacks.picker.grep({
    cwd = picker_cwd(),
  })
end

function M.setup()
  require("snacks").setup({
    picker = {
      enabled = true,
      ui_select = true,
    },
    statuscolumn = {
      enabled = true,
    },
  })

  require("snacks.picker").setup()
end

return M
