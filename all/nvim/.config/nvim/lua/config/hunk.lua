local M = {}

local function trim(value)
  return (value or ""):gsub("%s+$", "")
end

local function in_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
end

local function system(args, opts)
  opts = opts or {}

  local result = vim.system(args, {
    cwd = opts.cwd,
    text = true,
  }):wait()

  if result.code ~= 0 then
    if opts.notify ~= false then
      local err = trim(result.stderr)
      if err ~= "" then
        vim.notify(err, vim.log.levels.ERROR)
      end
    end
    return nil
  end

  return trim(result.stdout)
end

local function tmux(args)
  if not in_tmux() then
    vim.notify("Not running inside tmux", vim.log.levels.WARN)
    return nil
  end

  return system(vim.list_extend({ "tmux" }, args))
end

local function pane_exists(target)
  return target and target ~= "" and system({ "tmux", "list-panes", "-t", target }, { notify = false }) ~= nil
end

local function current_file()
  local file = vim.api.nvim_buf_get_name(0)
  return file ~= "" and vim.fn.fnamemodify(file, ":p") or nil
end

local function current_dir()
  local file = current_file()
  if file then
    return vim.fs.dirname(file)
  end

  return vim.fn.getcwd()
end

local function repo_root()
  local root = system({ "git", "rev-parse", "--show-toplevel" }, {
    cwd = current_dir(),
    notify = false,
  })

  if not root then
    vim.notify("Current buffer is not in a git repo", vim.log.levels.WARN)
    return nil
  end

  return root
end

local function relative_file(root)
  local file = current_file()
  if not file then
    return nil
  end

  local prefix = root .. "/"
  if file:sub(1, #prefix) ~= prefix then
    return nil
  end

  return file:sub(#prefix + 1)
end

local function base_ref(root)
  for _, ref in ipairs({ "origin/main", "main", "origin/master", "master" }) do
    if system({ "git", "rev-parse", "--verify", ref }, { cwd = root, notify = false }) then
      return ref
    end
  end
end

local function shelljoin(args)
  return table.concat(vim.tbl_map(vim.fn.shellescape, args), " ")
end

local function managed_target()
  return vim.g.hunk_tmux_managed_target
end

local function open_in_pane(cmd, cwd)
  local target = managed_target()
  if pane_exists(target) then
    M.close()
  end

  local pane = tmux({
    "split-window",
    "-dP",
    "-F",
    "#{pane_id}",
    "-c",
    cwd,
    "-h",
    "-l",
    "55%",
    "exec " .. shelljoin(cmd),
  })

  if not pane or pane == "" then
    vim.notify("Failed to open hunk pane", vim.log.levels.ERROR)
    return
  end

  vim.g.hunk_tmux_managed_target = pane
end

function M.close()
  local target = managed_target()
  if not target then
    vim.notify("No managed hunk pane", vim.log.levels.WARN)
    return
  end

  if pane_exists(target) then
    tmux({ "kill-pane", "-t", target })
  end

  vim.g.hunk_tmux_managed_target = nil
end

function M.focus()
  local target = managed_target()
  if not pane_exists(target) then
    vim.g.hunk_tmux_managed_target = nil
    return false
  end

  tmux({ "select-pane", "-t", target })
  return true
end

function M.open()
  if not M.focus() then
    M.menu()
  end
end

function M.menu()
  local root = repo_root()
  if not root then
    return
  end

  local file = relative_file(root)
  local base = base_ref(root)
  local items = {
    {
      label = "Hunk current changes",
      cmd = { "hunk", "diff", "--watch" },
    },
  }

  if base then
    items[#items + 1] = {
      label = "Hunk branch changes vs " .. base,
      cmd = { "hunk", "diff", base .. "...HEAD" },
    }
  end

  if file then
    items[#items + 1] = {
      label = "Hunk current file",
      cmd = { "hunk", "diff", "--watch", "--", file },
    }

    if base then
      items[#items + 1] = {
        label = "Hunk current file vs " .. base,
        cmd = { "hunk", "diff", base .. "...HEAD", "--", file },
      }
    end
  end

  vim.ui.select(items, {
    prompt = "Open Hunk review",
    format_item = function(item)
      return item.label
    end,
  }, function(item)
    if item then
      open_in_pane(item.cmd, root)
    end
  end)
end

return M
