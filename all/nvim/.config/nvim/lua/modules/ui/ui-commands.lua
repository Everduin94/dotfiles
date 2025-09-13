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

return M
