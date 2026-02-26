local SubMode = require("modules.sub_mode.sub_mode")

-- Git
vim.keymap.set("n", "<leader>gk", function()
  require("gitsigns").nav_hunk("next")
  require("gitsigns").nav_hunk("prev")
  vim.keymap.set("n", "<TAB>", "<cmd>lua require([[gitsigns]]).nav_hunk('next')<CR>")
  vim.keymap.set("n", "<S-TAB>", "<cmd>lua require([[gitsigns]]).nav_hunk('prev')<CR>")
  SubMode.set("Git")
end, { desc = "Git Hunk Mode" })

-- Diagnostic
vim.keymap.set("n", "<leader>gn", function()
  vim.diagnostic.jump({ count = 1, float = true })
  vim.keymap.set("n", "<TAB>", "<cmd>lua vim.diagnostic.jump({ count = 1, float = true })<CR>")
  vim.keymap.set("n", "<S-TAB>", "<cmd>lua vim.diagnostic.jump({ count = -1, float = true })<CR>")
  SubMode.set("Diagnostic")
end, { desc = "Diagnostic Mode" })

-- Quick Fix
vim.keymap.set("n", "<leader>gx", function()
  vim.api.nvim_command("copen")
  vim.keymap.set("n", "<TAB>", "<cmd>cn<CR>zz")
  vim.keymap.set("n", "<S-TAB>", "<cmd>cp<CR>zz")
  SubMode.set("Quick Fix")
end, { desc = "Quick Fix Mode" })

-- Clear → Buffer
vim.keymap.set("n", "<leader>g/", function()
  vim.keymap.set("n", "<TAB>", "<cmd>bnext<CR>")
  vim.keymap.set("n", "<S-TAB>", "<cmd>bprevious<CR>")
  SubMode.set("Buffer")
end, { desc = "Buffer Mode" })

-- Spellcheck
vim.keymap.set("n", "<leader>gp", function()
  vim.api.nvim_feedkeys("]s", "n", false)
  vim.keymap.set("n", "<TAB>", "]s")
  vim.keymap.set("n", "<S-TAB>", "[s")
  SubMode.set("Spellcheck")
end, { desc = "Spellcheck Mode" })
