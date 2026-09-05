local M = {}

local hunk_terminal

local function trim(value)
  return (value or ""):gsub("%s+$", "")
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

local function terminal_valid()
  return hunk_terminal and hunk_terminal:buf_valid()
end

local function open_in_terminal(cmd, cwd)
  M.close()

  hunk_terminal = Snacks.terminal.open(cmd, {
    cwd = cwd,
    win = {
      position = "right",
      width = 0.55,
    },
  })
  hunk_terminal:focus()
end

function M.close()
  if terminal_valid() then
    hunk_terminal:close()
  end
  hunk_terminal = nil
end

function M.focus()
  if not terminal_valid() then
    hunk_terminal = nil
    return false
  end

  if not hunk_terminal:win_valid() then
    hunk_terminal:show()
  end
  hunk_terminal:focus()
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
      open_in_terminal(item.cmd, root)
    end
  end)
end

return M
