local M = {}

vim.api.nvim_set_hl(0, "MarkviewBlockQuoteDefault", { fg = "#e0def4" })
vim.api.nvim_set_hl(0, "MarkviewBlockQuoteError", { fg = "#eb6f92" }) -- red
vim.api.nvim_set_hl(0, "MarkviewBlockQuoteNote", { fg = "#3e8fb0" }) -- blue
-- vim.api.nvim_set_hl(0, "MarkviewBlockQuoteOk", { fg = "#9ccfd8" }) -- green
vim.api.nvim_set_hl(0, "MarkviewBlockQuoteSpecial", { fg = "#c4a7e7" }) -- purple
vim.api.nvim_set_hl(0, "MarkviewBlockQuoteWarn", { fg = "#f6c177" }) -- yellow
vim.api.nvim_set_hl(0, "MarkviewBlockQuoteOk", { fg = "#4a9a6f" }) -- green
vim.api.nvim_set_hl(0, "MarkviewCheckboxChecked", { fg = "#4a9a6f" }) -- green
vim.api.nvim_set_hl(0, "MarkviewCheckboxUnchecked", { fg = "#9ccfd8" }) -- green
vim.api.nvim_set_hl(0, "MarkviewInlineCode", { fg = "#3e8fb0", bg = "#1e1e2e" }) -- blue fg, soft bg
vim.api.nvim_set_hl(0, "@markup.raw.markdown_inline", { fg = "#3e8fb0" }) -- blue fg, soft bg
vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#6c7086" }) -- blue fg, soft bg
vim.api.nvim_set_hl(0, "Delimiter", { fg = "#bac2de" }) -- blue fg, soft bg
vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = "#bac2de" }) -- blue fg, soft bg
vim.api.nvim_set_hl(0, "MatchParen", { fg = "#f2cdcd", bg = "NONE" }) -- blue fg, soft bg #7dc4e4
vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#313244" }) -- blue fg, soft bg
vim.api.nvim_set_hl(0, "Type", { fg = "#CDD6f4" }) -- white

-- Minimal Theme Implementation
vim.api.nvim_set_hl(0, "@type.builtin", { fg = "#CDD6f4" }) -- white
vim.api.nvim_set_hl(0, "@lsp.typemod.parameter.declaration.typescript", { fg = "#f5c2e7" }) -- high priority but softer than Function
vim.api.nvim_set_hl(0, "@lsp.typemod.parameter.declaration.svelte", { fg = "#f5c2e7" }) -- high priority but softer than Function
vim.api.nvim_set_hl(0, "@function.builtin", { fg = "#CDD6f4" }) -- white
vim.api.nvim_set_hl(0, "@variable.member", { fg = "#CDD6f4" }) -- white
vim.api.nvim_set_hl(0, "@variable.parameter", { fg = "#CDD6f4" }) -- white
vim.api.nvim_set_hl(0, "@lsp.mod.declaration.typescript", { fg = "#CDD6f4" }) -- white
vim.api.nvim_set_hl(0, "@variable.builtin", { fg = "#CDD6f4", italic = true }) -- white
vim.api.nvim_set_hl(0, "@property", { fg = "#CDD6f4" }) -- white
vim.api.nvim_set_hl(0, "Type", { fg = "#CDD6f4" }) -- white
vim.api.nvim_set_hl(0, "Function", { fg = "#b4befe" }) -- white
-- vim.api.nvim_set_hl(0, "Function", { fg = "#CDD6f4" }) -- white
vim.api.nvim_set_hl(0, "Operator", { fg = "#bac2de" }) -- sub white
vim.api.nvim_set_hl(0, "Special", { fg = "#bac2de" }) -- sub white
vim.api.nvim_set_hl(0, "@parameter", { fg = "NONE" }) -- remove color
vim.api.nvim_set_hl(0, "String", { fg = "#94e2d5" })
vim.api.nvim_set_hl(0, "Number", { fg = "#94e2d5" })
vim.api.nvim_set_hl(0, "Boolean", { fg = "#94e2d5" })
vim.api.nvim_set_hl(0, "Keyword", { fg = "#f5e0dc", italic = true }) -- soft color with italic
vim.api.nvim_set_hl(0, "Exception", { fg = "#f5e0dc", italic = true }) -- soft color with italic
vim.api.nvim_set_hl(0, "@keyword.function", { fg = "#f5e0dc", italic = true }) -- soft color with italic
vim.api.nvim_set_hl(0, "@keyword.export", { fg = "#f5e0dc", italic = true }) -- soft color with italic
vim.api.nvim_set_hl(0, "@keyword.operator", { fg = "#f5e0dc", italic = true }) -- soft color with italic
vim.api.nvim_set_hl(0, "Conditional", { fg = "#f5e0dc", italic = true }) -- soft color with italic
vim.api.nvim_set_hl(0, "@keyword.return", { fg = "#f5e0dc", italic = true }) -- soft color with italic
vim.api.nvim_set_hl(0, "Include", { fg = "#f5e0dc", italic = true }) -- soft color with italic
vim.api.nvim_set_hl(0, "@lsp.mod.declaration.typescript", { fg = "#89b4fa" }) -- high priority color (yellow)
vim.api.nvim_set_hl(0, "@lsp.typemod.variable.declaration.svelte", { fg = "#89b4fa" }) -- high priority color (yellow)
vim.api.nvim_set_hl(0, "@lsp.typemod.function.declaration.svelte", { fg = "#89b4fa" }) -- high priority color (yellow)
vim.api.nvim_set_hl(0, "@lsp.mod.declaration.typescript", { fg = "#89b4fa" }) -- high priority color (yellow)
vim.api.nvim_set_hl(0, "@constructor.typescript", { fg = "#89b4fa" }) -- high priority color (yellow)
vim.api.nvim_set_hl(0, "@lsp.typemod.property.declaration.typescript", { fg = "#CDD6f4" }) -- white
-- @lsp.typemod.function.declaration.svelte

--
-- vim.api.nvim_set_hl(0, "Comment", { fg = "#89b4fa", italic = true }) -- Blue comments 👀
-- vim.api.nvim_set_hl(0, "Function", { fg = "#89dceb" }) -- Is getting overwritten by mod declaration
-- vim.api.nvim_set_hl(0, "@lsp.typemod.parameter.declaration.typescript", { fg = "#89dceb" }) -- high priority but softer than Function
-- vim.api.nvim_set_hl(0, "@constructor.typescript", { fg = "#89dceb", italic = true }) --
-- vim.api.nvim_set_hl(0, "@lsp.typemod.parameter.declaration.typescript", { fg = "#f9e2af" }) -- high priority but softer than Function
-- vim.api.nvim_set_hl(0, "@lsp.mod.declaration.typescript", { fg = "#89dceb" }) -- high priority color (cyan)

-- vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "#1e1e2e" })
-- vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "#1e1e2e" })
-- Only set if NVIM_TRANSPARENT is == to 1
if os.getenv("NVIM_TRANSPARENT") ~= "1" then
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#181825" })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#89b4fa", bg = "#181825" })
  vim.api.nvim_set_hl(0, "FloatTitle", { fg = "#89b4fa", bg = "#181825" })
  vim.api.nvim_set_hl(0, "Pmenu", { bg = "#181825" })
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#1e1e2e" }) -- selected item
  vim.api.nvim_set_hl(0, "PmenuBorder", { bg = "#181825", fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "PmenuDoc", { bg = "#181825" }) -- docs popup
  vim.api.nvim_set_hl(0, "PmenuDocBorder", { bg = "#181825", fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { bg = "#181825", fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { bg = "#181825", fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "TroubleNormal", { bg = "#181825" })
  vim.api.nvim_set_hl(0, "TroubleNormalNC", { bg = "#181825" })
  vim.api.nvim_set_hl(0, "TroubleCount", { bg = "#181825" }) -- optional: for number counters
  vim.api.nvim_set_hl(0, "TroubleText", { bg = "#181825" })
  vim.api.nvim_set_hl(0, "TermNormal", { bg = "#181825" })
  vim.api.nvim_set_hl(0, "TermNormalNC", { bg = "#181825" })
  vim.api.nvim_set_hl(0, "TermBg", { bg = "#181825" })
  vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
      vim.opt_local.winhighlight = "Normal:TermBg"
    end,
  })
end
vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { fg = "#eb6f92" })
-- vim.api.nvim_set_hl(0, "CursorLine", { bg = "#181825" })

-- vim.diagnostic.config = {
--   float = {
--     -- UI.
--     header = false,
--     border = "rounded",
--     focusable = true,
--   },
-- }

-- vim.api.nvim_set_hl(0, "SnacksPickerList", { bg = "#181825" })
-- vim.api.nvim_set_hl(0, "SnacksPickerListBorder", { bg = "#181825", fg = "#89b4fa" })
-- vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", { bg = "#181825", fg = "#89b4fa" })
-- vim.api.nvim_set_hl(0, "SnacksPickerListFooter", { bg = "#181825" })
-- vim.api.nvim_set_hl(0, "SnacksPickerListTitle", { bg = "#181825" })
-- vim.api.nvim_set_hl(0, "SnacksPickerInput", { bg = "#181825" })
-- vim.api.nvim_set_hl(0, "SnacksPickerInputBorder", { bg = "#181825" })
-- vim.api.nvim_set_hl(0, "SnacksPickerInputFooter", { bg = "#181825" })
-- vim.api.nvim_set_hl(0, "SnacksPickerInputSearch", { bg = "#181825", fg = "#89b4fa" })
-- vim.api.nvim_set_hl(0, "SnacksPickerInputTitle", { bg = "#181825" })

return M
