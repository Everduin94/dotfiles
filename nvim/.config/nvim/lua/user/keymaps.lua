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

local function leaderCategory(key, name)
  NORMAL_MAPS["<leader>" .. key] = { name }
end

local function category(key, name)
  NORMAL_MAPS[key] = { name }
end

local function lspMap(key, fn, desc)
  desc = desc or fn;
  NORMAL_MAPS[key] = { "<cmd>" .. fn .. "<cr>", desc }
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
keymap("i", "<C-g>", "<Nop>", opts)

-- Navigation
  -- Panes
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>k", opts)
keymap("n", "<C-k>", "<C-w>j", opts)
keymap("n", "<C-l>", "<C-w>l", opts)
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
leaderMap("oa", "e#", "Alternate")

  -- End of Line
keymap("n", "H", "^", opts)
keymap("v", "H", "^", opts)
keymap("o", "H", "^", opts)
keymap("n", "L", "$", opts)
keymap("v", "L", "$", opts)
keymap("o", "L", "$", opts)

  -- Buffers
keymap("n", "<TAB>", ":bnext<CR>", opts)
keymap("n", "<S-TAB>", ":bprevious<CR>", opts)
keymap("n", "<C-s>", ":wa<CR>", opts)


  -- Opposite day
keymap("n", "j", "<Up>", opts)
keymap("n", "k", "<Down>", opts)
keymap("n", "J", "{zz", opts)
keymap("n", "K", "}zz", opts)
keymap("x", "j", "<Up>", opts)
keymap("x", "k", "<Down>", opts)
keymap("x", "J", "{zz", opts)
keymap("x", "K", "}zz", opts)
keymap("o", "J", "{zz", opts)
keymap("o", "K", "}zz", opts)
keymap("o", "j", "<Up>", opts)
keymap("o", "k", "<Down>", opts)
keymap("n", "gj", "gk", opts)
keymap("n", "gk", "gj", opts)

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
-- Debug (DAP)
leaderCategory('d', '+Debugger')
  -- Debugger
luaMap('dd', 'dap', 'continue()')
luaMap('db', 'dap', 'toggle_breakpoint()')
luaMap('dr', 'dap', 'repl.open()')
luaMap('dl', 'dap', 'set_breakpoint(nil, nil, vim.fn.input("Log point message: "))')
  -- UI
luaMap('du', 'dapui', 'toggle()')

-- Git
leaderCategory('g', '+Git')
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
luaMap('q', 'harpoon.ui', 'toggle_quick_menu()')

-- Misc
-- leaderMap('q', 'w\\|bd', "") -- I think the problem is \ was meant to dereference |
leaderMap('/', 'noh', "Clear Highlights")
leaderMap('tj', 'e temp.js | Codi', "Codi Javascript")
keymap("n", "<leader>k", "K", opts)
keymap('n', '<leader>j', "J", opts)

-- Terminal
leaderCategory('t', '+Terminal')
  -- Harpoon
luaMap('tc', 'harpoon.cmd-ui', 'toggle_quick_menu()')
luaMap('t1', 'harpoon.term', 'gotoTerminal(1)')
luaMap('t2', 'harpoon.term', 'gotoTerminal(2)')
luaMap('t3', 'harpoon.term', 'gotoTerminal(3)')

  -- ToggleTerm
leaderMap('tn', 'lua _NODE_TOGGLE()', "Node")
leaderMap('tc', 'lua _NG_SERVE_TOGGLE()', "ng serve")
leaderMap('tj', 'lua _JEST_TOGGLE()', "Jest")
leaderMap('t6', 'lua _CWD_TOGGLE()', "CWD")

-- Search
leaderCategory('p', '+Telescope')
  -- Telescope
   -- E means "exclude", must have fd installed.
local grepFilter = '!*{.spec.ts,.yaml,.json,fixture*}'
local fileFilter = '{ "fd", "--type", "f", "--glob", "-E", "{*.spec.ts,*.yaml,*.json,*fixture*}" }'
luaMap('pp', 'telescope.builtin', 'find_files({ find_command = ' .. fileFilter ..  ' })')
luaMap('pf', 'telescope.builtin', 'live_grep({glob_pattern = "' .. grepFilter .. '"})')
luaMap('pb', 'telescope.builtin', 'buffers()')
luaMap('p*', 'telescope.builtin', 'grep_string()')
luaMap('po', 'telescope.builtin', 'find_files({ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] })', 'Find Files(Git Root)')
luaMap('pg', 'telescope.builtin', 'live_grep{ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] }', 'Grep(Git Root)' )
luaMap('pn', 'telescope.builtin', 'live_grep{ cwd = "~/dev/notes" }',  'Grep(Notes)')
luaMap('pc', 'telescope.builtin', 'live_grep{ cwd = "~/dev/notes/creative-work/cheatsheets" }', 'Grep(Cheatsheets)')
luaMap('pl', 'telescope.builtin', 'live_grep{ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] .. "/libs" , glob_pattern = "' .. grepFilter .. '" }', 'Grep(Nx Libs)' )
luaMap('pl', 'telescope.builtin', 'find_files{ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] .. "/libs" , find_command = "' .. fileFilter .. '" }', 'Grep(Nx Libs)' )

  -- Telescope:Help
luaMap('ph', 'telescope.builtin', 'highlights()')
luaMap('pm', 'telescope.builtin', 'man_pages()')
luaMap('p?', 'telescope.builtin', 'help_tags()')
  -- Telescope:Git
leaderCategory('pt', '+Git Telescope')
luaMap('pts', 'telescope.builtin', 'git_status()')
luaMap('ptb', 'telescope.builtin', 'git_branches()')
luaMap('ptc', 'telescope.builtin', 'git_commits()')
  -- Dashboard
leaderMap('ps', 'Alpha', 'Dashboard')
  -- Nvim Tree
leaderMap("'", 'NvimTreeToggle', 'Explorer')

-- Quickfix
leaderCategory('c', '+QuickFix')
leaderMap('co', 'copen', 'Open')
leaderMap('cl', 'cclose', 'Close')

-- Splits
leaderCategory('v', '+Splits')
leaderMap('vk', '15sp', 'Split Down')
leaderMap('vl', '65vsp', 'Split Right')
leaderMap('vc', 'close', 'Close Split')
leaderMap('v]', 'vertical resize +5', '⬅️')
leaderMap('v[', 'vertical resize -5', '➡️')
leaderMap('v=', 'vertical resize -5', '⬇️')
leaderMap('v-', 'vertical resize -5', '⬆️')
-- leaderMap('\\', '<C-W>=', 'Balance')
-- leaderMap('|', '<C-W>|', 'Hide')

-- LSP
lspMap("gd", "lua vim.lsp.buf.definition()", "Definition")
lspMap("gD", "lua vim.lsp.buf.declaration()", "Declaration")
lspMap("gr", "lua vim.lsp.buf.references()", "References")
lspMap("gi", "lua vim.lsp.buf.implementation()", "Implementation")
category("gl", "+LSP Actions")
lspMap("gli", "lua vim.lsp.buf.hover()", "Hover")
lspMap("gls", "lua vim.lsp.buf.signature_help()", "Signature Popup")
lspMap("glr", "lua vim.lsp.buf.rename()", "Rename")
lspMap("glc", "lua vim.lsp.buf.code_action()", "Code Action")
lspMap("<C-p>", "lua vim.diagnostic.goto_next()", "Go to Next")
lspMap("<C-n>", "lua vim.diagnostic.goto_prev()", "Go to Previous")

-- Vim Wiki
leaderMap("wo", "VimwikiGoBackLink", "Go back")
leaderMap("wp", "VimwikiFollowLink", "Folow link")
leaderMap("wl", "VimwikiNextLink", "Next Link")
leaderMap("wh", "VimwikiPrevLink", "Prev Link")
leaderMap("wm", "VimwikiTable", "Create Table")
leaderMap("wq", ":%bd", "Quit All")

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

keymap("n", "<Leader>wnn", "<Plug>VimwikiNextLink", {})
keymap("n", "<Leader>wnN", "<Plug>VimwikiPrevLink", {})

-- Emmet
-- TODO: You can't use nore for things like <C-y>
  -- Balance outward
macOrLinux(os, "n", "<A-h>", "˙", "<C-y>d", {})
macOrLinux(os, "i", "<A-h>", "˙", "<C-y>d", {})
macOrLinux(os, "v", "<A-h>", "˙", "<C-y>d", {})
  -- Balance inward
macOrLinux(os, "n", "<A-l>", "¬", "<C-y>D", {})
macOrLinux(os, "i", "<A-l>", "¬", "<C-y>D", {})
macOrLinux(os, "v", "<A-l>", "¬", "<C-y>D", {})
  -- Next Edit
macOrLinux(os, "n", "<A-o>", "ø", "<C-y>n", {})
macOrLinux(os, "i", "<A-o>", "ø", "<C-y>n", {})
  -- Previous Edit
macOrLinux(os, "n", "<A-s-o>", "Ø", "<C-y>N", {})
macOrLinux(os, "i", "<A-s-o>", "Ø", "<C-y>N", {})
-- Dap: TODO: Configure for mac
macOrLinux(os, "n", "<A-e>", "<A-e>", "<cmd>lua require'dap'.step_over()<CR>", opts)
macOrLinux(os, "n", "<A-r>", "<A-e>", "<cmd>lua require'dap'.step_into()<CR>", opts)
macOrLinux(os, "n", "<A-t>", "<A-e>", "<cmd>lua require'dap'.step_out()<CR>", opts)

