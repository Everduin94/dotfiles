local M = {}

-- Each segment sits between two triangle glyphs colored like its bg, which
-- makes the slants. Left segments slope down, right ones slope up, and edges
-- that touch the screen stay straight. The bar itself uses the editor bg.
local slants = {
  down = { left = "\u{e0be}", right = "\u{e0b8}" },
  up = { left = "\u{e0ba}", right = "\u{e0bc}" },
}

-- How far section bgs move toward the editor bg.
local section_dim = 0.3

local icons = {
  branch = "\u{e725}", -- 
  modified = "\u{25cf}", -- ●
  file = "\u{f0214}", -- 󰈔
  terminal = "\u{e795}", -- 
  zmx = "\u{f165d}", -- 󱙝
}

-- Same glyphs as mini.icons.
local ft_icons = {
  lua = "\u{f08b1}",
  typescript = "\u{f06e6}",
  javascript = "\u{f031e}",
  typescriptreact = "\u{e7ba}",
  javascriptreact = "\u{e625}",
  html = "\u{f031d}",
  htmlangular = "\u{f06b2}",
  css = "\u{f031c}",
  scss = "\u{f07ec}",
  json = "\u{f0626}",
  jsonc = "\u{f0626}",
  markdown = "\u{f0354}",
  zig = "\u{e6a9}",
  svelte = "\u{e697}",
  python = "\u{f0320}",
  sh = "\u{e691}",
  bash = "\u{e691}",
  zsh = "\u{e691}",
  go = "\u{f07d3}",
  rust = "\u{f1617}",
  yaml = "\u{e6a8}",
  toml = "\u{e6b2}",
  vim = "\u{e7c5}",
  gitcommit = "\u{f02a2}",
  dockerfile = "\u{f0868}",
  sql = "\u{f01bc}",
  oil = "\u{f0645}",
  help = "\u{f02d6}",
  text = "\u{f09aa}",
  c = "\u{f0671}",
  cpp = "\u{f0672}",
  codecompanion = "\u{f06a9}",
}

local caps = {}

local function get_hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

local function mix(a, b, t)
  local function ch(x, shift)
    return math.floor(x / 2 ^ shift) % 256
  end
  local out = 0
  for _, shift in ipairs({ 16, 8, 0 }) do
    local x, y = ch(a, shift), ch(b, shift)
    out = out + math.floor(x + (y - x) * t + 0.5) * 2 ^ shift
  end
  return out
end

-- Runs on every ColorScheme.
local function apply_highlights()
  local normal = get_hl("Normal")
  local stl = get_hl("StatusLine")
  local devinfo = get_hl("MiniStatuslineDevinfo")

  -- first of these that differs from the editor bg
  local section_bg = devinfo.bg
  for _, bg in ipairs({ devinfo.bg, stl.bg, get_hl("CursorLine").bg }) do
    if bg and bg ~= normal.bg then
      section_bg = bg
      break
    end
  end
  if section_bg and normal.bg then
    section_bg = mix(section_bg, normal.bg, section_dim)
  end
  vim.api.nvim_set_hl(0, "StlSection", { fg = devinfo.fg or stl.fg or normal.fg, bg = section_bg })
  local function fg_of(name)
    return get_hl(name).fg
  end
  local chat_fg = {
    Idle = devinfo.fg or stl.fg or normal.fg,
    Running = fg_of("DiagnosticWarn"),
    Done = fg_of("DiagnosticOk"),
  }
  for state, fg in pairs(chat_fg) do
    vim.api.nvim_set_hl(0, "StlChat" .. state, { fg = fg, bg = section_bg })
    -- the chat you're in is underlined
    vim.api.nvim_set_hl(0, "StlChat" .. state .. "Cur", { fg = fg, bg = section_bg, underline = true, bold = true })
  end

  local nc = get_hl("StatusLineNC")
  vim.api.nvim_set_hl(0, "StatusLine", { fg = stl.fg, bg = normal.bg or "NONE" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = nc.fg, bg = normal.bg or "NONE" })
  vim.api.nvim_set_hl(0, "MiniStatuslineInactive", { link = "StatusLineNC" })
  caps = {}
end

--- Highlight for a segment's slanted edge.
local function cap_hl(hl)
  if caps[hl] then
    return caps[hl]
  end
  local name = "StlCap_" .. hl
  vim.api.nvim_set_hl(0, name, { fg = get_hl(hl).bg, bg = get_hl("StatusLine").bg })
  caps[hl] = name
  return name
end

local function esc(text)
  return (text:gsub("%%", "%%%%"))
end

-- Ghostty draws an icon across the space after it, so icon-only segments get
-- an extra space on the right.
local pad = { left = 1, right = 1, icon_right = 2 }

--- opts.slope: "down" (left side) or "up" (default)
--- opts.edge: "left" or "right" keeps that side straight
--- opts.icon: text is a single icon
local function seg(hl, text, opts)
  if not text or text == "" then
    return ""
  end
  opts = opts or {}
  local glyph = slants[opts.slope or "up"]
  local cap = cap_hl(hl)
  local left = opts.edge == "left" and "" or ("%%#%s#%s"):format(cap, glyph.left)
  local right = opts.edge == "right" and "" or ("%%#%s#%s"):format(cap, glyph.right)
  local lpad = (" "):rep(pad.left)
  local rpad = (" "):rep(opts.icon and pad.icon_right or pad.right)
  return ("%s%%#%s#%s%s%s%s"):format(left, hl, lpad, text, rpad, right)
end

-- Git branch, cached per buffer and refreshed async.
local function refresh_branch(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local name = vim.api.nvim_buf_get_name(buf)
  local dir = vim.fn.getcwd()
  if name:match("^oil://") then
    dir = name:gsub("^oil://", "")
  elseif vim.bo[buf].buftype == "" and name ~= "" then
    dir = vim.fs.dirname(name)
  end
  if vim.fn.isdirectory(dir) == 0 then
    return
  end

  vim.system({ "git", "-C", dir, "rev-parse", "--abbrev-ref", "HEAD" }, { text = true }, function(out)
    local branch = out.code == 0 and vim.trim(out.stdout or "") or ""
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) and vim.b[buf].stl_branch ~= branch then
        vim.b[buf].stl_branch = branch
        vim.cmd.redrawstatus()
      end
    end)
  end)
end

local function section_mode()
  local mode, hl = MiniStatusline.section_mode({ trunc_width = 80 })
  return mode:upper(), hl
end

local function section_branch()
  local branch = vim.b.stl_branch
  if not branch or branch == "" then
    return ""
  end
  -- everduin94/fix/154-branch-format -> 154-branch-format
  return icons.branch .. " " .. esc(branch:match("[^/]+$") or branch)
end

--- Parent dir + file, e.g. config/statusline.lua.
local function section_filename()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype == "codecompanion" then
    -- the model, or "pi" until pi reports it
    return esc(require("config.ai").chat_model(buf) or "pi")
  end
  if vim.bo[buf].buftype == "terminal" then
    local index = require("config.terminal").index_of(buf)
    return icons.terminal .. " " .. (index and ("T" .. index) or "term")
  end

  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return "[No Name]"
  end
  name = name:gsub("^oil://", "")

  local rel = vim.fn.fnamemodify(name, ":~:.")
  local parts = vim.split(rel, "/", { trimempty = true })
  local short = table.concat(vim.list_slice(parts, math.max(1, #parts - 1)), "/")
  if vim.bo[buf].filetype == "oil" then
    short = short .. "/"
  end

  local flags = ""
  if vim.bo[buf].modified then
    flags = " " .. icons.modified
  elseif vim.bo[buf].readonly or not vim.bo[buf].modifiable then
    flags = " ro"
  end
  return esc(short) .. flags
end

--- Ghost when Neovim runs in a zmx session.
local function section_zmx()
  return (vim.env.ZMX_SESSION and vim.env.ZMX_SESSION ~= "") and icons.zmx or ""
end

--- One icon per chat: ○ idle, ◐ running, ● done but not seen.
local chat_hl = { idle = "StlChatIdle", running = "StlChatRunning", done = "StlChatDone" }
local function section_chats()
  if not package.loaded["config.ai"] then
    return ""
  end
  local items = require("config.ai").chat_status()
  if #items == 0 then
    return ""
  end
  local parts = {}
  for _, item in ipairs(items) do
    local hl = chat_hl[item.state] .. (item.current and "Cur" or "")
    table.insert(parts, ("%%#%s#%s%%#StlSection#"):format(hl, item.icon))
  end
  return table.concat(parts, " ")
end

local function section_ft_icon()
  local ft = vim.bo.filetype
  if ft_icons[ft] then
    return ft_icons[ft]
  end
  if vim.bo.buftype == "terminal" then
    return icons.terminal
  end
  if ft == "" then
    return ""
  end
  return icons.file
end

-- One global statusline or one per window (<leader>us).
local global_file = vim.fn.stdpath("state") .. "/statusline-global"
local global = (function()
  local ok, lines = pcall(vim.fn.readfile, global_file)
  return not (ok and lines[1] == "off")
end)()

local function apply_laststatus()
  vim.o.laststatus = global and 3 or 2
end

function M.toggle_global()
  global = not global
  pcall(vim.fn.writefile, { global and "on" or "off" }, global_file)
  apply_laststatus()
  vim.notify("Statusline: " .. (global and "global" or "per window"))
end

---------------------------------------------------------------------------
function M.setup()
  require("mini.statusline").setup({
    content = {
      active = function()
        local mode, mode_hl = section_mode()
        local part = "StlSection"

        return table.concat({
          seg(mode_hl, mode, { edge = "left", slope = "down" }),
          seg(part, section_branch(), { slope = "down" }),
          seg(part, require("config.submode").icon(), { slope = "down", icon = true }),
          "%#StatusLine#%<%=",
          seg(part, section_zmx(), { icon = true }),
          seg(part, section_chats()),
          seg(part, section_filename()),
          seg(mode_hl, section_ft_icon(), { edge = "right", icon = true }),
        })
      end,
      inactive = function()
        return "%#MiniStatuslineInactive# " .. section_filename() .. "%="
      end,
    },
  })

  -- the bar shares the editor bg, so never let Neovim fill it with ^^^
  vim.opt.fillchars:append({ stl = " ", stlnc = " " })
  apply_laststatus() -- after mini.statusline, which sets laststatus=2
  vim.keymap.set("n", "<leader>us", M.toggle_global, { desc = "Toggle global / per-window statusline" })
  vim.api.nvim_create_user_command("StatuslineGlobal", M.toggle_global, { desc = "Toggle global statusline" })

  apply_highlights()
  local group = vim.api.nvim_create_augroup("config_statusline", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = apply_highlights })
  vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "DirChanged" }, {
    group = group,
    callback = function()
      refresh_branch()
    end,
  })
end

return M
