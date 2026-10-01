local M = {}

local function apply_highlights()
  local color = "#6c7086"

  local ok, palettes = pcall(require, "catppuccin.palettes")
  if vim.g.colors_name and vim.g.colors_name:find("^catppuccin") and ok then
    local palette = palettes.get_palette("mocha")
    color = palette.overlay0 or color
  else
    local hl = vim.api.nvim_get_hl(0, { name = "NonText", link = false })
    color = hl.fg and string.format("#%06x", hl.fg) or color
  end

  vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = color, nocombine = true })
  vim.api.nvim_set_hl(0, "MiniIndentscopeSymbolOff", { fg = color, nocombine = true })
end

function M.setup()
  require("mini.indentscope").setup()
  apply_highlights()

  local group = vim.api.nvim_create_augroup("pi-mini-indentscope", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = apply_highlights,
  })
end

return M
