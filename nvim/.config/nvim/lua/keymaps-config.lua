-- Goals
-- Move ALL keymaps to here
-- Ideally, a function that could handle adding to which key

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

local function leaderMap(key, fn)
  keymap("n", "<leader>" .. key, "<cmd>" .. fn .. "<cr>", opts)
end

-- Debug
  -- UI
leaderMap('du', 'lua require("dapui").toggle()')

-- Git
  -- Git Signs
leaderMap('gk', 'lua require("gitsigns").next_hunk()')
leaderMap('gj', 'lua require("gitsigns").prev_hunk()')
leaderMap('gu', 'lua require("gitsigns").reset_hunk()')
leaderMap('gp', 'lua require("gitsigns").preview_hunk()')
leaderMap('gcb', 'lua require("gitsigns").toggle_current_line_blame()')

-- Search
  -- Telescope
leaderMap('pp', 'lua require("telescope.builtin").find_files()')
leaderMap('pf', 'lua require("telescope.builtin").live_grep()')
leaderMap('pb', 'lua require("telescope.builtin").buffers()')
leaderMap('p*', 'lua require("telescope.builtin").grep_string()')
leaderMap('po', 'lua require("telescope.builtin").find_files({ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] })')
leaderMap('pg', 'lua require("telescope.builtin").live_grep{ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] }')
leaderMap('pn', 'lua require("telescope.builtin").live_grep{ cwd = "~/dev/notes" }')
leaderMap('pc', 'lua require("telescope.builtin").live_grep{ cwd = "~/dev/notes/creative-work/cheatsheets" }')
  -- Telescope:Help
leaderMap('ph', 'lua require("telescope.builtin").highlights()')
leaderMap('pm', 'lua require("telescope.builtin").man_pages()')
leaderMap('p?', 'lua require("telescope.builtin").help_tags()')
  -- Telescope:Git
leaderMap('pgs', 'lua require("telescope.builtin").git_status()')
leaderMap('pgb', 'lua require("telescope.builtin").git_branches()')
leaderMap('pgc', 'lua require("telescope.builtin").git_commits()')
