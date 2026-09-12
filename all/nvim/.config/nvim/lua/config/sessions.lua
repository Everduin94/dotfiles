local M = {}

-- Sessions are scoped per project directory (like `auto-session`), but keyed
-- and stored the mini.sessions way: named files inside
-- `MiniSessions.config.directory`, never a `Session.vim` dropped into the
-- project itself (that would need gitignoring in every repo). The name
-- mirrors the cwd path with `/` swapped for `%%`, which also keeps it a
-- single path segment.
local function session_name()
  local cwd = vim.fn.getcwd()
  return (cwd:gsub("/", "%%")) .. ".vim"
end

-- Cheap approximation of MiniSessions' own "don't clobber whatever the user
-- is trying to show" guard (it also checks buffer/file state, but this
-- covers the common case: a bare `nvim` with no file args in a project dir).
local function is_something_shown()
  return vim.fn.argc() > 0 or vim.bo.filetype ~= "" or vim.api.nvim_buf_line_count(0) > 1
end

function M.setup()
  local sessions = require("mini.sessions")

  sessions.setup({
    -- Autoread/autowrite are handled below, keyed by cwd instead of
    -- mini.sessions' own "local Session.vim in cwd" / "most recent
    -- session anywhere" defaults.
    autoread = false,
    autowrite = false,
    file = "",
    verbose = { read = false, write = false, delete = true },
  })

  local group = vim.api.nvim_create_augroup("pi-mini-sessions", { clear = true })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    nested = true,
    once = true,
    callback = function()
      if is_something_shown() then
        return
      end

      local name = session_name()
      if sessions.detected[name] then
        pcall(sessions.read, name)
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    once = true,
    callback = function()
      pcall(sessions.write, session_name(), { force = true })
    end,
  })
end

-- Manual escape hatch for `<leader>ss` — always saves under this
-- directory's session name, even if no session was auto-loaded yet.
function M.write()
  require("mini.sessions").write(session_name(), { force = true })
end

-- Manual escape hatch for `<leader>sl` — pick any detected session (not just
-- the one for the current directory) to load.
function M.select()
  require("mini.sessions").select("read")
end

return M
