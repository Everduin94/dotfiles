local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  print('Which-Key is not loaded!')
  return
end

-- SETUP
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
local wopts = { mode = "n", noremap = true, silent = true, buffer = nil }

NORMAL_MAPS = {}
local function leaderMap(key, fn, desc)
  desc = desc or fn;
  NORMAL_MAPS["<leader>" .. key] = { "<cmd>" .. fn .. "<cr>", desc }
end

local function luaMap(key, module, fn, desc)
  desc = desc or fn;
  NORMAL_MAPS["<leader>" .. key] = { "<cmd>lua require('".. module .. "')." .. fn ..  "<cr>", desc }
end

local function category(key, name)
  NORMAL_MAPS["<leader>" .. key] = { name }
end

-- MAPPINGS
-- Leader
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Tabbing
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
keymap("n", "<", "<<", opts)
keymap("n", ">", ">>", opts)

-- Navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>k", opts)
keymap("n", "<C-k>", "<C-w>j", opts)
keymap("n", "<C-l>", "<C-w>l", opts)
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

keymap("n", "H", "^", opts)
keymap("v", "H", "^", opts)
keymap("o", "H", "^", opts)
keymap("n", "L", "$", opts)
keymap("v", "L", "$", opts)
keymap("o", "L", "$", opts)

keymap("n", "<TAB>", ":bnext<CR>", opts)
keymap("n", "<S-TAB>", ":bprevious<CR>", opts)
keymap("n", "<C-s>", ":wa<CR>", opts)

-- Undo break points
keymap("i", ",", ",<c-g>u", opts)
keymap("i", ".", ".<c-g>u", opts)
keymap("i", "!", "!<c-g>u", opts)
keymap("i", "?", "?<c-g>u", opts)

-- Center when X
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Better highlight to end
keymap("n", "yL", "yg_", opts)

-- LEADER
-- Debug
category('d', '+Debugger')
  -- UI
luaMap('du', 'dapui', 'toggle()')

-- Git
category('g', '+Git')
  -- Git Signs
luaMap('gk', 'gitsigns', 'next_hunk()')
luaMap('gj', 'gitsigns', 'prev_hunk()')
luaMap('gu', 'gitsigns', 'reset_hunk()')
luaMap('gp', 'gitsigns', 'preview_hunk()')
luaMap('gcb', 'gitsigns', 'toggle_current_line_blame()')
  -- Fugitive
leaderMap('gf', 'G', 'Fugitive')
leaderMap('gb', 'Git blame', 'Blame')
leaderMap('gl', 'Git log', 'Log')
leaderMap('gv', 'Gvdiffsplit', 'Diff Split')
leaderMap('gw', 'Git difftool', 'Diff Tool')
leaderMap('ge', 'Git mergetool', 'Merge Tool')

-- Harpoon
luaMap('0', 'harpoon.mark', 'add_file()')
luaMap('1', 'harpoon.ui', 'nav_file(1)')
luaMap('2', 'harpoon.ui', 'nav_file(2)')
luaMap('3', 'harpoon.ui', 'nav_file(3)')
luaMap('4', 'harpoon.ui', 'nav_file(4)')
luaMap('e', 'harpoon.ui', 'toggle_quick_menu()')

-- Buffers
-- leaderMap('q', 'w\\|bd', "") -- TODO: Test
leaderMap('/', 'noh', "Clear Highlights")
keymap("n", "<leader>k", "K", opts)
keymap('n', '<leader>j', "J", opts)

-- Terminal
category('t', '+Terminal')
  -- Harpoon
luaMap('tc', 'harpoon.cmd-ui', 'toggle_quick_menu()')
luaMap('t1', 'harpoon.term', 'gotoTerminal(1)')
luaMap('t2', 'harpoon.term', 'gotoTerminal(2)')
luaMap('t3', 'harpoon.term', 'gotoTerminal(3)')
  -- ToggleTerm
leaderMap('tn', 'lua _NODE_TOGGLE()', "Node")

-- Search
category('p', '+Telescope')
  -- Telescope
luaMap('pp', 'telescope.builtin', 'find_files()')
luaMap('pf', 'telescope.builtin', 'live_grep()')
luaMap('pb', 'telescope.builtin', 'buffers()')
luaMap('p*', 'telescope.builtin', 'grep_string()')
luaMap('po', 'telescope.builtin', 'find_files({ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] })', 'Find Files(Git Root)')
luaMap('pg', 'telescope.builtin', 'live_grep{ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] }', 'Grep(Git Root)' )
luaMap('pn', 'telescope.builtin', 'live_grep{ cwd = "~/dev/notes" }',  'Grep(Notes)')
luaMap('pc', 'telescope.builtin', 'live_grep{ cwd = "~/dev/notes/creative-work/cheatsheets" }', 'Grep(Cheatsheets)')
  -- Telescope:Help
luaMap('ph', 'telescope.builtin', 'highlights()')
luaMap('pm', 'telescope.builtin', 'man_pages()')
luaMap('p?', 'telescope.builtin', 'help_tags()')
  -- Telescope:Git
category('pt', '+Git Telescope')
luaMap('pts', 'telescope.builtin', 'git_status()')
luaMap('ptb', 'telescope.builtin', 'git_branches()')
luaMap('ptc', 'telescope.builtin', 'git_commits()')
  -- Dashboard
leaderMap('ps', 'Alpha', 'Dashboard')

-- Quickfix
category('c', '+QuickFix')
leaderMap('co', 'copen', 'Open')
leaderMap('cl', 'cclose', 'Close')

-- Splits
category('v', '+Splits')
leaderMap('vk', '15sp', 'Split Down')
leaderMap('vl', '65vsp', 'Split Right')
leaderMap('vc', 'close', 'Close Split')
leaderMap('v]', 'vertical resize +5', '⬅️')
leaderMap('v[', 'vertical resize -5', '➡️')
leaderMap('v=', 'vertical resize -5', '⬇️')
leaderMap('v-', 'vertical resize -5', '⬆️')
-- leaderMap('\\', '<C-W>=', 'Balance')
-- leaderMap('|', '<C-W>|', 'Hide')

which_key.register(NORMAL_MAPS, wopts)

-- MAC & LINUX (Alt Keybinds)
local function macOrLinux(os, mode, linux_bind, mac_bind, fn, opt)
  if os == "Linux" then
    keymap(mode, linux_bind, fn, opt)
  else
    keymap(mode, mac_bind, fn, opt)
  end
end

local os = vim.loop.os_uname().sysname
-- General
  -- Quickfix List
macOrLinux(os, "n", "<A-q>", "œ",  ":bd!<CR>", opts)
macOrLinux(os, "n", "<A-z>", "Ω", ":cp<CR>zz", opts)
macOrLinux(os, "n", "<A-x>", "≈", ":cn<CR>zz", opts)
macOrLinux(os, "n", "<A-k>", "˚", "<esc>:m .+1<CR>==", opts)
macOrLinux(os, "n", "<A-j>", "∆", "<esc>:m .-2<CR>==", opts)
macOrLinux(os, "v", "<A-k>", "˚", ":m '>+1<CR>gv=gv", opts)
macOrLinux(os, "v", "<A-j>", "∆", ":m '<-2<CR>gv=gv", opts)
macOrLinux(os, "t", "<A-\\>", "«", "<C-\\><C-N>", term_opts)
-- Emmet: TODO Original emmet binds were not noremap, is this okay?
  -- Balance outward
macOrLinux(os, "n", "<A-h>", "˙", "<C-y>d", opts)
macOrLinux(os, "i", "<A-h>", "˙", "<C-y>d", opts)
macOrLinux(os, "v", "<A-h>", "˙", "<C-y>d", opts)
  -- Balance inward
macOrLinux(os, "n", "<A-l>", "¬", "<C-y>D", opts)
macOrLinux(os, "i", "<A-l>", "¬", "<C-y>D", opts)
macOrLinux(os, "v", "<A-l>", "¬", "<C-y>D", opts)
  -- Expand: TODO: Add g on mac
macOrLinux(os, "n", "<A-,>", "≤", "<C-y>,", opts)
macOrLinux(os, "i", "<A-,>", "≤", "<C-y>,", opts)
macOrLinux(os, "n", "<A-g>", "≤", "<C-y>,", opts)
macOrLinux(os, "i", "<A-g>", "≤", "<C-y>,", opts)
  -- Next Edit
macOrLinux(os, "n", "<A-o>", "ø", "<C-y>n", opts)
macOrLinux(os, "i", "<A-o>", "ø", "<C-y>n", opts)
  -- Previous Edit
macOrLinux(os, "n", "<A-s-o>", "Ø", "<C-y>N", opts)
macOrLinux(os, "i", "<A-s-o>", "Ø", "<C-y>N", opts)

