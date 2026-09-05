local M = {}

local zmx_terminal

local function current_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Current buffer has no file", vim.log.levels.WARN)
    return nil
  end

  return vim.fn.fnamemodify(file, ":p")
end

local function current_cwd()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then
    return vim.fs.dirname(vim.fn.fnamemodify(file, ":p"))
  end

  return vim.fn.getcwd()
end

local function selection_text()
  local lines = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.visualmode() })
  return table.concat(lines, "\n")
end

local function zmx_valid()
  return zmx_terminal and zmx_terminal:buf_valid()
end

local function zmx_channel()
  if not zmx_valid() then
    vim.notify("Open and attach with <leader>tg first", vim.log.levels.WARN)
    return nil
  end

  local channel = vim.b[zmx_terminal.buf].terminal_job_id
  if not channel then
    vim.notify("The zmx terminal is not ready", vim.log.levels.WARN)
    return nil
  end

  return channel
end

local function show_zmx()
  if not zmx_valid() then
    return false
  end

  if not zmx_terminal:win_valid() then
    zmx_terminal:show()
  end
  zmx_terminal:focus()
  return true
end

local function send(text, opts)
  opts = opts or {}
  if not text or text == "" then
    return
  end

  local channel = zmx_channel()
  if not channel then
    return
  end

  local payload = "\27[200~" .. text .. "\27[201~"
  if opts.submit ~= false then
    payload = payload .. "\r"
  end
  vim.api.nvim_chan_send(channel, payload)
end

function M.toggle(index)
  Snacks.terminal.toggle(nil, { count = index })
end

function M.toggle_zmx()
  if not zmx_valid() then
    local shell = vim.env.SHELL or "/bin/zsh"
    zmx_terminal = Snacks.terminal.open({ shell, "-ic", "while zmx-select; do :; done" }, {
      cwd = current_cwd(),
      win = {
        position = "right",
        width = 0.4,
      },
    })
    zmx_terminal:focus()
    return
  end

  if zmx_terminal:win_valid() then
    if vim.api.nvim_get_current_win() == zmx_terminal.win then
      zmx_terminal:hide()
    else
      zmx_terminal:focus()
    end
  else
    show_zmx()
  end
end

function M.focus_zmx()
  if not show_zmx() then
    M.toggle_zmx()
  end
end

function M.detach_zmx()
  local channel = zmx_channel()
  if not channel then
    return
  end

  -- zmx uses Ctrl-\ (ASCII FS) to detach the current client.
  vim.api.nvim_chan_send(channel, "\28")
  vim.defer_fn(show_zmx, 100)
end

function M.send_selection()
  send(selection_text(), { submit = false })
end

function M.send_this()
  local file = current_file()
  if not file then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  send(("%s:%d:%d"):format(file, cursor[1], cursor[2] + 1))
end

function M.send_file()
  local file = current_file()
  if file then
    send(file, { submit = false })
  end
end

function M.prompt()
  local input = vim.fn.input("zmx> ")
  if input ~= "" then
    send(input)
  end
end

function M.send_range(line1, line2)
  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
  send(table.concat(lines, "\n"))
end

return M
