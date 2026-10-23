local M = {}

-- Darker bg for the CodeCompanion chat, terminals, and Oil (<leader>ub).
-- Uses the theme's sidebar bg if it has one, otherwise darkens the editor bg.

local fallback_darken = 0.25
local panel_filetypes = { codecompanion = true, oil = true }
local mapping =
  "Normal:DarkPanel,NormalNC:DarkPanel,SignColumn:DarkPanel,EndOfBuffer:DarkPanel,MarkviewCodeBar:MarkviewCodeBarPanel"

local state_file = vim.fn.stdpath("state") .. "/dark-panels"
local enabled = true

local function get_hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

local function darken(color, t)
  local out = 0
  for _, shift in ipairs({ 16, 8, 0 }) do
    local ch = math.floor(color / 2 ^ shift) % 256
    out = out + math.floor(ch * (1 - t) + 0.5) * 2 ^ shift
  end
  return out
end

--- The dark panel bg for the current theme, or nil.
function M.dark_bg()
  local normal = get_hl("Normal")
  local bg = get_hl("NormalSB").bg
  if not bg or bg == normal.bg then
    bg = normal.bg and darken(normal.bg, fallback_darken) or nil
  end
  return bg
end

local function apply_highlight()
  vim.api.nvim_set_hl(0, "DarkPanel", { fg = get_hl("Normal").fg, bg = M.dark_bg() })
end

local function is_panel(buf)
  return vim.bo[buf].buftype == "terminal" or panel_filetypes[vim.bo[buf].filetype] == true
end

local function update(win)
  if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_config(win).relative ~= "" then
    return
  end
  local want = enabled and is_panel(vim.api.nvim_win_get_buf(win))
  local current = vim.wo[win].winhighlight
  local has = current:find(mapping, 1, true) ~= nil

  if want and not has then
    vim.wo[win].winhighlight = current == "" and mapping or (current .. "," .. mapping)
  elseif not want and has then
    -- splits copy 'winhighlight', so strip it instead of restoring a saved value
    local rest = current:gsub(",?" .. vim.pesc(mapping), ""):gsub("^,", "")
    vim.wo[win].winhighlight = rest
  end
end

local function update_all()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    update(win)
  end
end

function M.toggle()
  enabled = not enabled
  pcall(vim.fn.writefile, { enabled and "on" or "off" }, state_file)
  update_all()
  vim.notify("Dark panels: " .. (enabled and "on" or "off"))
end

function M.setup()
  local ok, lines = pcall(vim.fn.readfile, state_file)
  enabled = not (ok and lines[1] == "off")

  apply_highlight()
  local group = vim.api.nvim_create_augroup("config_panels", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = apply_highlight })
  vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "TermOpen", "WinNew" }, {
    group = group,
    callback = function()
      update(vim.api.nvim_get_current_win())
    end,
  })

  vim.keymap.set("n", "<leader>ub", M.toggle, { desc = "Toggle dark panels (chat / terminal / oil)" })
  vim.api.nvim_create_user_command("DarkPanels", M.toggle, { desc = "Toggle dark panel backgrounds" })
  update_all()
end

return M
