local M = {}

local terminals = {}
local buf_to_index = {}

function M.index_of(buffer)
  return buf_to_index[buffer]
end

-- <leader>t1..4 share one right split (33%). Opening a terminal focuses it if
-- it's already showing, otherwise swaps it into that split; the old one keeps
-- running hidden.
--
-- This might be too rigid. If it doesn't fit every situation, add a picker
-- that opens 1-4 in a specific window.
local term_win
local term_width = 0.33

local function term_window()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    return term_win
  end
  vim.cmd("botright vsplit")
  term_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(term_win, math.floor(vim.o.columns * term_width))
  vim.wo[term_win].winfixwidth = true
  return term_win
end

local function show(buffer)
  local shown = vim.fn.win_findbuf(buffer)[1]
  local win = shown or term_window()
  vim.api.nvim_set_current_win(win)
  if not shown then
    vim.api.nvim_win_set_buf(win, buffer)
  end
  vim.cmd.startinsert()
end

function M.open(index)
  local buffer = terminals[index]
  if buffer and vim.api.nvim_buf_is_valid(buffer) then
    show(buffer)
    return
  end

  local cwd = vim.fn.getcwd(0)
  local shell = vim.env.SHELL or vim.o.shell
  buffer = vim.api.nvim_create_buf(false, true)
  terminals[index] = buffer
  buf_to_index[buffer] = index
  vim.bo[buffer].bufhidden = "hide"
  vim.api.nvim_set_current_win(term_window())
  vim.api.nvim_win_set_buf(0, buffer)

  local job = vim.fn.jobstart({ shell }, { cwd = cwd, term = true })
  if job <= 0 then
    terminals[index] = nil
    buf_to_index[buffer] = nil
    vim.api.nvim_buf_delete(buffer, { force = true })
    vim.notify("Could not start terminal " .. index, vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buffer,
    once = true,
    callback = function()
      terminals[index] = nil
      buf_to_index[buffer] = nil
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buffer) then
          vim.api.nvim_buf_delete(buffer, { force = true })
        end
      end)
    end,
  })
end

return M
