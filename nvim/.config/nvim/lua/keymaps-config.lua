-- Goals
-- Move ALL keymaps to here
-- Ideally, a function that could handle adding to which key

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- TODO: Handle cmd
local function leaderMap(key, fn)
  keymap("n", "<leader>" .. key, "<cmd>" .. fn .. "<cr>", opts)
end


leaderMap('du', 'lua require("dapui").toggle()')
leaderMap('gk', 'lua require("gitsigns").next_hunk()')
leaderMap('gj', 'lua require("gitsigns").prev_hunk()')
leaderMap('gu', 'lua require("gitsigns").reset_hunk()')
leaderMap('gp', 'lua require("gitsigns").preview_hunk()')

