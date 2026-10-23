local M = {}

-- CodeCompanion talks to pi through pi-acp (npm install -g pi-acp), which runs
-- `pi --mode rpc`. Chats get your pi models, skills, prompts, and extensions.
-- pi edits files on disk with its own tools, so open buffers get :checktime
-- while a chat runs.

local function pi_command()
  if vim.fn.executable("pi-acp") == 1 then
    return { "pi-acp" }
  end
  return { "npx", "-y", "pi-acp" }
end

-- Chat state for the statusline: idle, running, or done (finished, not seen yet).
local chats = {} -- ordered by creation: { bufnr = n, state = "idle"|"running"|"done" }
local spinner = { "◐", "◓", "◑", "◒" }
local frame = 1
local timer
local ticks = 0

local function find(bufnr)
  for i, chat in ipairs(chats) do
    if chat.bufnr == bufnr then
      return chat, i
    end
  end
end

local function any_running()
  for _, chat in ipairs(chats) do
    if chat.state == "running" then
      return true
    end
  end
  return false
end

local function redraw()
  vim.schedule(function()
    vim.cmd.redrawstatus({ bang = true })
  end)
end

-- markview only re-renders the focused buffer, so a chat streaming in another
-- window would stay raw.
local function render_chat(bufnr)
  if not package.loaded["markview"] or #vim.fn.win_findbuf(bufnr) == 0 then
    return
  end
  if vim.api.nvim_get_current_buf() == bufnr and vim.fn.mode():find("^i") then
    return
  end
  pcall(require("markview").render, bufnr)
end

-- "working…" virtual line under a running chat. Moved to the last line each
-- tick so it stays below the reply.
local working_ns = vim.api.nvim_create_namespace("config_ai_working")
local function update_working(chat)
  if not vim.api.nvim_buf_is_valid(chat.bufnr) then
    return
  end
  if chat.state ~= "running" then
    vim.api.nvim_buf_clear_namespace(chat.bufnr, working_ns, 0, -1)
    chat.working_id = nil
    return
  end
  local last = vim.api.nvim_buf_line_count(chat.bufnr) - 1
  chat.working_id = vim.api.nvim_buf_set_extmark(chat.bufnr, working_ns, last, 0, {
    id = chat.working_id,
    virt_lines = {
      { { "", "Normal" } }, -- blank line above
      { { spinner[frame] .. " ", "DiagnosticWarn" }, { "working…", "Comment" } },
    },
  })
end

-- Runs while any chat is running.
local function update_timer()
  if any_running() then
    if timer then
      return
    end
    timer = vim.uv.new_timer()
    timer:start(
      0,
      150,
      vim.schedule_wrap(function()
        frame = frame % #spinner + 1
        ticks = ticks + 1
        for _, chat in ipairs(chats) do
          if chat.state == "running" then
            update_working(chat)
          end
        end
        if ticks % 7 == 0 then -- ~1s
          pcall(vim.cmd.checktime)
        end
        if ticks % 3 == 0 then -- ~0.5s
          for _, chat in ipairs(chats) do
            if chat.state == "running" then
              render_chat(chat.bufnr)
            end
          end
        end
        vim.cmd.redrawstatus({ bang = true })
      end)
    )
  elseif timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

local function set_state(bufnr, state)
  local chat = find(bufnr)
  if not chat then
    chat = { bufnr = bufnr }
    table.insert(chats, chat)
  end
  chat.state = state
  update_working(chat)
  update_timer()
  redraw()
end

--- { { state, icon, current }, ... } in creation order.
function M.chat_status()
  local current = vim.api.nvim_get_current_buf()
  return vim.tbl_map(function(chat)
    local icon = chat.state == "running" and spinner[frame] or chat.state == "done" and "●" or "○"
    return { state = chat.state, icon = icon, current = chat.bufnr == current }
  end, chats)
end

--- Model of a chat buffer without the provider, nil until pi reports it.
function M.chat_model(bufnr)
  local meta = _G.codecompanion_chat_metadata and _G.codecompanion_chat_metadata[bufnr]
  local model = meta and meta.adapter and meta.adapter.model
  if not model or model == "default" then
    return nil
  end
  return (model:gsub("^.*/", ""))
end

local function track()
  local group = vim.api.nvim_create_augroup("config_ai_chats", { clear = true })
  local function on(pattern, fn)
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = pattern,
      callback = function(args)
        local bufnr = args.data and args.data.bufnr
        if bufnr then
          fn(bufnr)
        end
      end,
    })
  end

  on("CodeCompanionChatCreated", function(bufnr)
    set_state(bufnr, "idle")
  end)
  on("CodeCompanionChatSubmitted", function(bufnr)
    set_state(bufnr, "running")
  end)
  on("CodeCompanionChatStopped", function(bufnr)
    set_state(bufnr, "idle")
  end)
  on("CodeCompanionChatDone", function(bufnr)
    -- "done" only if it finished off screen
    set_state(bufnr, #vim.fn.win_findbuf(bufnr) > 0 and "idle" or "done")
    pcall(vim.cmd.checktime)
    vim.schedule(function()
      render_chat(bufnr)
    end)
  end)
  on("CodeCompanionChatModel", function()
    redraw()
  end)
  on("CodeCompanionChatClosed", function(bufnr)
    local _, i = find(bufnr)
    if i then
      table.remove(chats, i)
    end
    update_timer()
    redraw()
  end)

  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(args)
      local chat = find(args.buf)
      if chat and chat.state == "done" then
        set_state(args.buf, "idle")
      end
    end,
  })
end

-- <leader>at / af / av add a reference to the last chat's input and leave you
-- in insert mode. Nothing is sent until you submit.

local function relpath(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return nil
  end
  return vim.fn.fnamemodify(name, ":.")
end

local function send(lines)
  local cc = require("codecompanion")
  local chat = cc.last_chat() or cc.chat({ stop_context_insertion = true })
  if not chat then
    vim.notify("Could not open a chat", vim.log.levels.WARN)
    return
  end
  chat.ui:open()

  local buf = chat.bufnr
  local last = vim.api.nvim_buf_line_count(buf)
  local last_line = vim.api.nvim_buf_get_lines(buf, last - 1, last, false)[1]
  if last_line == "" then
    vim.api.nvim_buf_set_lines(buf, last - 1, last, false, lines)
  else
    vim.api.nvim_buf_set_lines(buf, last, last, false, lines)
  end

  local win = vim.fn.win_findbuf(buf)[1]
  if win then
    vim.api.nvim_set_current_win(win)
    vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
    vim.cmd("startinsert!")
  end
end

--- Visual selection as `path:Lx-Ly` + fenced code.
local function selection_lines()
  local buf = vim.api.nvim_get_current_buf()
  local path = relpath(buf) or "[No Name]"
  local s, e = vim.fn.getpos("v"), vim.fn.getpos(".")
  if s[2] > e[2] then
    s, e = e, s
  end
  local mode = vim.fn.mode()
  local code = vim.fn.getregion(s, e, { type = mode })
  vim.cmd("normal! \27") -- leave visual mode
  local lines = { ("`%s:L%d-L%d`"):format(path, s[2], e[2]), "```" .. vim.bo[buf].filetype }
  vim.list_extend(lines, code)
  table.insert(lines, "```")
  return lines
end

function M.send_this()
  if vim.fn.mode():find("^[vV\22]") then
    return send(selection_lines())
  end
  local path = relpath(0)
  if not path then
    return vim.notify("Current buffer has no file", vim.log.levels.WARN)
  end
  local pos = vim.api.nvim_win_get_cursor(0)
  send({ ("`%s:L%d:C%d`"):format(path, pos[1], pos[2] + 1) })
end

function M.send_file()
  local path = relpath(0)
  if not path then
    return vim.notify("Current buffer has no file", vim.log.levels.WARN)
  end
  send({ ("`%s`"):format(path) })
end

function M.send_selection()
  send(selection_lines())
end

---------------------------------------------------------------------------
function M.setup()
  require("codecompanion").setup({
    adapters = {
      acp = {
        pi = function()
          -- opencode's adapter skips ACP auth; pi handles its own.
          return require("codecompanion.adapters").extend("opencode", {
            name = "pi",
            formatted_name = "pi",
            commands = { default = pi_command() },
            defaults = { timeout = 30000 },
          })
        end,
      },
    },
    interactions = {
      chat = { adapter = "pi" },
      inline = { adapter = "pi" },
    },
    display = {
      chat = {
        show_reasoning = false,
        window = {
          layout = "vertical",
          position = "right",
          width = 0.4,
        },
      },
    },
  })
  track()

  local map = vim.keymap.set
  map({ "n", "x" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "AI chat toggle (pi)" })
  map("n", "<leader>an", "<cmd>CodeCompanionChat<cr>", { desc = "AI new chat" })
  map({ "n", "x" }, "<leader>aA", "<cmd>CodeCompanionActions<cr>", { desc = "AI chat actions palette" })
  map("x", "<leader>aC", "<cmd>CodeCompanionChat Add<cr>", { desc = "AI add selection to chat" })
  map({ "n", "x" }, "<leader>ai", ":CodeCompanion ", { silent = false, desc = "AI inline prompt" })
  map({ "n", "x" }, "<leader>at", M.send_this, { desc = "AI chat: send this (position / selection)" })
  map("n", "<leader>af", M.send_file, { desc = "AI chat: send file" })
  map("x", "<leader>av", M.send_selection, { desc = "AI chat: send selection" })
end

return M
