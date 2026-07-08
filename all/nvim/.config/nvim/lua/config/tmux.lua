local M = {}

local function trim(value)
  return (value or ""):gsub("%s+$", "")
end

local function in_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
end

local function run(args)
  if not in_tmux() then
    vim.notify("Not running inside tmux", vim.log.levels.WARN)
    return nil
  end

  local result = vim.system(vim.list_extend({ "tmux" }, args), { text = true }):wait()
  if result.code ~= 0 then
    local err = (result.stderr or ""):gsub("%s+$", "")
    if err ~= "" then
      vim.notify(err, vim.log.levels.ERROR)
    end
    return nil
  end

  return result
end

local function display(format)
  local result = run({ "display-message", "-p", format })
  if not result then
    return nil
  end

  return trim(result.stdout)
end

local function pane_exists(target)
  if not in_tmux() or not target or target == "" then
    return false
  end

  local result = vim.system({ "tmux", "list-panes", "-t", target }, { text = true }):wait()
  return result.code == 0
end

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

local function tmux_panes()
  local result = run({
    "list-panes",
    "-a",
    "-F",
    table.concat({
      "#{session_name}",
      "#{window_index}.#{pane_index}",
      "#{pane_id}",
      "#{pane_pid}",
      "#{pane_current_command}",
      "#{pane_current_path}",
    }, "\t"),
  })
  if not result then
    return {}
  end

  local panes = {}
  for line in (result.stdout or ""):gmatch("[^\r\n]+") do
    local session, window, id, pid, command, cwd = line:match("^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t(.*)$")
    if session and window and id and pid and command and cwd then
      panes[#panes + 1] = {
        session = session,
        window = window,
        id = id,
        pid = tonumber(pid),
        command = command,
        cwd = cwd,
      }
    end
  end

  return panes
end

local function ps_snapshot()
  local result = vim.system({ "ps", "-ax", "-o", "pid=", "-o", "ppid=", "-o", "command=" }, { text = true }):wait()
  if result.code ~= 0 then
    local err = trim(result.stderr)
    if err ~= "" then
      vim.notify(err, vim.log.levels.ERROR)
    end
    return nil
  end

  local snapshot = { children = {}, commands = {} }
  for line in (result.stdout or ""):gmatch("[^\r\n]+") do
    local pid, ppid, command = line:match("^%s*(%d+)%s+(%d+)%s+(.*)$")
    if pid and ppid and command then
      pid = tonumber(pid)
      ppid = tonumber(ppid)
      snapshot.children[ppid] = snapshot.children[ppid] or {}
      snapshot.children[ppid][#snapshot.children[ppid] + 1] = pid
      snapshot.commands[pid] = command
    end
  end

  return snapshot
end

local function descendant_pids(snapshot, root_pid)
  local ret = { root_pid }
  local stack = { root_pid }
  local seen = { [root_pid] = true }

  while #stack > 0 do
    local pid = table.remove(stack)
    for _, child in ipairs(snapshot.children[pid] or {}) do
      if not seen[child] then
        seen[child] = true
        ret[#ret + 1] = child
        stack[#stack + 1] = child
      end
    end
  end

  return ret
end

local function is_pi_process(command)
  local exe = vim.fs.basename((command or ""):match("^%S+") or "")
  return exe == "pi"
end

local function pane_has_pi(pane_pid, snapshot)
  for _, pid in ipairs(descendant_pids(snapshot, pane_pid)) do
    if is_pi_process(snapshot.commands[pid]) then
      return true
    end
  end

  return false
end

local function bool(format)
  local value = display(format)
  return value == "1" or value == "true"
end

local function number(format)
  local value = display(format)
  return value and tonumber(value) or nil
end

local pane_edges = {
  ["-L"] = "#{pane_at_left}",
  ["-D"] = "#{pane_at_bottom}",
  ["-U"] = "#{pane_at_top}",
  ["-R"] = "#{pane_at_right}",
}

function M.navigate(win_cmd, pane_flag)
  local current = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. win_cmd)

  if vim.api.nvim_get_current_win() ~= current or not in_tmux() then
    return
  end

  local edge = pane_edges[pane_flag]
  if edge and bool(edge) then
    return
  end

  run({ "select-pane", pane_flag })
end

function M.next_window()
  if not in_tmux() or bool("#{window_end_flag}") then
    return
  end

  run({ "select-window", "-n" })
end

function M.previous_window()
  if not in_tmux() then
    return
  end

  local index = number("#{window_index}")
  local base = number("#{base-index}")

  if index == nil or base == nil or index <= base then
    return
  end

  run({ "select-window", "-p" })
end

function M.target()
  return vim.g.pi_tmux_target or "!"
end

function M.managed_target()
  return vim.g.pi_tmux_managed_target
end

function M.set_target(target)
  vim.g.pi_tmux_target = target ~= "" and target or nil
  vim.g.pi_tmux_managed_target = nil
end

function M.shell()
  local result = run({
    "split-window",
    "-dP",
    "-F",
    "#{pane_id}",
    "-c",
    current_cwd(),
    "-h",
    "-l",
    "40%",
  })

  if not result then
    return
  end

  local target = trim(result.stdout)
  if target == "" then
    vim.notify("Failed to open tmux shell pane", vim.log.levels.ERROR)
    return
  end

  run({ "select-pane", "-t", target })
end

function M.open()
  local managed = M.managed_target()
  if pane_exists(managed) then
    M.close()
  end

  local result = run({
    "split-window",
    "-dP",
    "-F",
    "#{pane_id}",
    "-c",
    current_cwd(),
    "-h",
    "-l",
    "40%",
    "pi",
  })

  if not result then
    return
  end

  local target = trim(result.stdout)
  if target == "" then
    vim.notify("Failed to open pi pane", vim.log.levels.ERROR)
    return
  end

  vim.g.pi_tmux_target = target
  vim.g.pi_tmux_managed_target = target
end

function M.close()
  local target = M.managed_target()
  if not target then
    vim.notify("No managed pi pane", vim.log.levels.WARN)
    return
  end

  if pane_exists(target) then
    run({ "kill-pane", "-t", target })
  end

  if vim.g.pi_tmux_target == target then
    vim.g.pi_tmux_target = nil
  end

  vim.g.pi_tmux_managed_target = nil
end

function M.attach()
  local snapshot = ps_snapshot()
  if not snapshot then
    return
  end

  local panes = vim.tbl_filter(function(pane)
    return pane.pid and pane_has_pi(pane.pid, snapshot)
  end, tmux_panes())

  if #panes == 0 then
    vim.notify("No tmux panes running pi", vim.log.levels.WARN)
    return
  end

  table.sort(panes, function(a, b)
    if a.session ~= b.session then
      return a.session < b.session
    end
    return a.window < b.window
  end)

  vim.ui.select(panes, {
    prompt = "Attach pi pane",
    format_item = function(item)
      return string.format("%s %s %s %s", item.session, item.window, item.id, item.cwd)
    end,
  }, function(item)
    if not item then
      return
    end

    M.set_target(item.id)
    vim.notify("Attached pi target " .. item.id)
  end)
end

function M.focus_target()
  run({ "select-pane", "-t", M.target() })
end

function M.send(text, opts)
  opts = opts or {}
  if text == nil or text == "" then
    return
  end

  if not run({ "set-buffer", "--", text }) then
    return
  end

  if not run({ "paste-buffer", "-d", "-t", M.target() }) then
    return
  end

  if opts.submit ~= false then
    run({ "send-keys", "-t", M.target(), "Enter" })
  end
end

function M.send_this()
  local file = current_file()
  if not file then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  M.send(("%s:%d:%d"):format(file, cursor[1], cursor[2] + 1))
end

function M.send_file()
  local file = current_file()
  if file then
    M.send(file)
  end
end

function M.send_selection()
  M.send(selection_text())
end

function M.prompt()
  local input = vim.fn.input("pi> ")
  if input ~= "" then
    M.send(input)
  end
end

function M.send_range(line1, line2)
  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
  M.send(table.concat(lines, "\n"))
end

return M
