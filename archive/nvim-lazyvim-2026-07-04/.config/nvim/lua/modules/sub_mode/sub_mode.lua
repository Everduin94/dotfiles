local M = {}

M.current = "Buffer"

local icons = {
  Buffer = "󰀘",
  ["Quick Fix"] = "",
  Git = "󰊢",
  Diagnostic = "󱩔",
  Spellcheck = "󰓆",
}

function M.set(mode)
  M.current = mode
end

function M.icon()
  return icons[M.current] or ""
end

return M
