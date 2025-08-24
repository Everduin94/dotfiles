local map = LazyVim.safe_keymap_set
local SubMode = require("modules.sub_mode.sub_mode")

-- Git
map("n", "<leader>gk", function()
  require("gitsigns").nav_hunk("next")
  require("gitsigns").nav_hunk("prev")
  map("n", "<TAB>", "<cmd>lua require([[gitsigns]]).nav_hunk('next')<CR>")
  map("n", "<S-TAB>", "<cmd>lua require([[gitsigns]]).nav_hunk('prev')<CR>")
  SubMode.set("Git")
end, { desc = "Git Hunk Mode" })

-- Diagnostic
map("n", "<leader>gn", function()
  vim.diagnostic.jump({ count = 1, float = true })
  map("n", "<TAB>", "<cmd>lua vim.diagnostic.jump({ count = 1, float = true })<CR>")
  map("n", "<S-TAB>", "<cmd>lua vim.diagnostic.jump({ count = -1, float = true })<CR>")
  SubMode.set("Diagnostic")
end, { desc = "Diagnostic Mode" })

-- Quick Fix
map("n", "<leader>gx", function()
  vim.api.nvim_command("copen")
  map("n", "<TAB>", "<cmd>cn<CR>zz")
  map("n", "<S-TAB>", "<cmd>cp<CR>zz")
  SubMode.set("Quick Fix")
end, { desc = "Quick Fix Mode" })

-- Clear → Buffer
map("n", "<leader>g/", function()
  map("n", "<TAB>", "<cmd>bnext<CR>")
  map("n", "<S-TAB>", "<cmd>bprevious<CR>")
  SubMode.set("Buffer")
end, { desc = "Buffer Mode" })

-- Spellcheck
map("n", "<leader>gp", function()
  vim.api.nvim_feedkeys("]s", "n", false)
  map("n", "<TAB>", "]s")
  map("n", "<S-TAB>", "[s")
  SubMode.set("Spellcheck")
end, { desc = "Spellcheck Mode" })
