local M = {}

local function apply_highlights()
  local color = "#6c7086"

  local ok, palettes = pcall(require, "catppuccin.palettes")
  if ok then
    local palette = palettes.get_palette("mocha")
    color = palette.overlay0 or color
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
