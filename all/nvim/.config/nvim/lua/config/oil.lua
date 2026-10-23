local M = {}

-- `-` opens Oil in a left panel. Picking a file opens it in the previous window
-- and closes the panel.
local panel_width = 35

local function is_panel(win)
  return win and vim.api.nvim_win_is_valid(win) and vim.w[win].oil_panel == true
end

local function panel_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_panel(win) then
      return win
    end
  end
end

--- A normal window to open files in, created if needed.
local function editor_win()
  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  local function usable(win)
    return win ~= 0 and vim.api.nvim_win_is_valid(win) and not is_panel(win) and vim.api.nvim_win_get_config(win).relative == ""
  end
  if usable(prev) then
    return prev
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if usable(win) then
      return win
    end
  end
  vim.cmd("botright vsplit")
  local win = vim.api.nvim_get_current_win()
  vim.wo[win].winfixwidth = false -- inherited from the panel
  vim.api.nvim_win_set_width(panel_win() or 0, panel_width)
  return win
end

--- Open or focus the panel with the cursor on the current file.
function M.open_panel()
  local source = vim.api.nvim_get_current_buf()
  local is_file = vim.bo[source].buftype == "" and vim.api.nvim_buf_get_name(source) ~= ""

  local win = panel_win()
  if win then
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd("topleft vsplit")
    win = vim.api.nvim_get_current_win()
    vim.w[win].oil_panel = true
    vim.wo[win].winfixwidth = true
    vim.api.nvim_win_set_width(win, panel_width)
  end

  if is_file then
    -- show the file first so oil.open() puts the cursor on it
    vim.api.nvim_win_set_buf(win, source)
    require("oil").open()
  else
    require("oil").open(vim.fn.getcwd())
  end
end

local function select()
  local oil = require("oil")
  local entry = oil.get_cursor_entry()
  local dir = oil.get_current_dir()
  if not is_panel(vim.api.nvim_get_current_win()) or not entry or not dir or entry.type == "directory" then
    oil.select()
    return
  end

  local path = dir .. entry.name
  local panel = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(editor_win())
  vim.cmd.edit(vim.fn.fnameescape(path))
  if vim.api.nvim_win_is_valid(panel) then
    vim.api.nvim_win_close(panel, false)
  end
end

local function close()
  local win = vim.api.nvim_get_current_win()
  if is_panel(win) and #vim.api.nvim_tabpage_list_wins(0) > 1 then
    vim.api.nvim_win_close(win, false)
    return
  end
  require("oil").close()
end

function M.setup()
  require("oil").setup({
    default_file_explorer = true,
    skip_confirm_for_simple_edits = true,
    keymaps = {
      ["<CR>"] = { callback = select, desc = "Open entry (panel: in previous window)" },
      ["<C-c>"] = { callback = close, mode = "n", desc = "Close panel / restore buffer" },
      ["q"] = { callback = close, mode = "n", desc = "Close panel / restore buffer" },
      -- keep <C-h>/<C-l> for window navigation
      ["<C-h>"] = false,
      ["<C-l>"] = false,
    },
    float = {
      border = "rounded",
      max_height = 0.9,
      max_width = 50,
      override = function(config)
        config.col = 0
        return config
      end,
    },
    view_options = {
      show_hidden = true,
      natural_order = true,
    },
  })
end

return M
