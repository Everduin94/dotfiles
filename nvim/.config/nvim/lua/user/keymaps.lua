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

local function escape(...)
 local command = type(...) == 'table' and ... or { ... }
 for i, s in ipairs(command) do
  s = (tostring(s) or ''):gsub('"', '\\"')
  if s:find '[^A-Za-z0-9_."/-]' then
  s = '"' .. s .. '"'
  elseif s == '' then
   s = '""'
  end
  command[i] = s
 end
 return table.concat(command, ' ')
end

function ev_selection()
  local home = os.getenv('HOME')
  local f = assert(io.open(home .. '/projects', "r"))
  local l = f:lines()
  local arr = {}
  for line in l do
     table.insert (arr, line);
  end
  f:close()
  return vim.ui.select(
    arr,
    { prompt = 'Projects:', format_item = function(item) return os.getenv(item:sub(2)) end, },
    function(choice) if choice then vim.cmd('cd ' .. os.getenv(choice:sub(2))) end end
  )
end
 
function go_to_alias(file_path)
  local home = os.getenv('HOME')
  local full_path = home .. '/' .. file_path
  local buf_name = vim.api.nvim_buf_get_name(0)
  local path_file_name = file_path:match('.+/(.+)$') or file_path
  local file_name = buf_name:match('.+/(.+)$')
  if file_name == path_file_name then
    vim.api.nvim_command('close')
  else
    vim.api.nvim_command('vsp ' .. full_path)
  end
end

leaderMap("/a", "lua go_to_alias('.config/zsh/zsh-aliases')", "Zsh Alias")
leaderMap("/e", "lua go_to_alias('.config/zsh/zsh-exports')", "Zsh Exports")
leaderMap("/s", "lua go_to_alias('.config/nvim/lua/user/luasnip.lua')", "Snippets")
leaderMap("/p", "lua go_to_alias('/projects')", "Projects")
leaderMap("pn", "lua " .. "ev_selection()", "CWD")
leaderMap("/c", "PickColor", "Pick Color")

vim.keymap.set('n', '<C-/>', 
    function()
        local result = vim.treesitter.get_captures_at_cursor(0)
        print(vim.inspect(result))
    end,
opts)

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
leaderMap("od", "e#", "Alternate")

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
keymap("n", "<C-x>", ":qa!<CR>", opts)

  -- Close, but doesn't handle copy from outside
-- keymap("v", "p", '"0p', opts)
-- keymap("v", "P", '"0P', opts)
-- keymap("n", "p", '"0p', opts)
-- keymap("n", "P", '"0P', opts)

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
luaMap('dl', 'dap', 'set_breakpoint(nil, nil, vim.fn.input("Log-ev: "))')
  -- UI
luaMap('du', 'dapui', 'toggle()')

-- SQL | DADBOD | DB
leaderMap('/d', 'DBUI', 'Dadbod')

-- Git
leaderCategory('g', '+Git')
  -- Git Signs
-- luaMap('gk', 'gitsigns', 'next_hunk()')
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

-- Zen
leaderCategory('z', '+Zen')
leaderMap('zm', 'TZAtaraxis', 'Zen Mode')
leaderMap('zn', 'TZFocus', 'Zen Focus')

-- Harpoon
luaMap('0', 'harpoon.mark', 'add_file()')
luaMap('1', 'harpoon.ui', 'nav_file(1)')
luaMap('2', 'harpoon.ui', 'nav_file(2)')
luaMap('3', 'harpoon.ui', 'nav_file(3)')
luaMap('4', 'harpoon.ui', 'nav_file(4)')
luaMap('q', 'harpoon.ui', 'toggle_quick_menu()')

-- Misc
-- leaderMap('q', 'w\\|bd', "") -- I think the problem is \ was meant to dereference |
keymap("n", "<leader>k", "K", opts)
keymap('n', '<leader>j', "J", opts)

-- Terminal
leaderCategory('t', '+Terminal')
leaderMap('t/', 'noh', "Clear Highlights")
leaderMap('tj', 'e temp.js | Codi', "Codi Javascript")
  -- Harpoon
luaMap('tc', 'harpoon.cmd-ui', 'toggle_quick_menu()')
luaMap('t1', 'harpoon.term', 'gotoTerminal(1)')
luaMap('t2', 'harpoon.term', 'gotoTerminal(2)')
luaMap('t3', 'harpoon.term', 'gotoTerminal(3)')
luaMap('t4', 'harpoon.term', 'gotoTerminal(4)')
luaMap('t6', 'harpoon.term', 'sendCommand(1, "<C-c>npm run dev")')
luaMap('t7', 'harpoon.term', 'sendCommand(1, "<C-c>npm run build")')
luaMap('t8', 'harpoon.term', 'sendCommand(2, "<C-c>npm run test")')
luaMap('t9', 'harpoon.term', 'sendCommand(3, "<C-c>l init")')

-- Codi
leaderMap('toc', 'Codi!!', "Toggle Codi")

-- Search
leaderCategory('p', '+Telescope')
  -- Telescope
   -- E means "exclude", must have fd installed.
local grepFilter = '!*{.spec.ts,.yaml,.xlf,bundle.js,.json,fixture*}'
local fileFilter = '{ "fd", "--type", "f", "--glob", "-E", "{*.spec.ts,*.yaml,*.xlf,*bundle.js,*.json,*fixture*}" }'
luaMap('pp', 'telescope.builtin', 'find_files({ find_command = ' .. fileFilter ..  ' })')
luaMap('pf', 'telescope.builtin', 'live_grep({glob_pattern = "' .. grepFilter .. '"})')
luaMap('pb', 'telescope.builtin', 'buffers()')
luaMap('p*', 'telescope.builtin', 'grep_string()')
luaMap('po', 'telescope.builtin', 'find_files({ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] })', 'Find Files(Git Root)')
luaMap('pg', 'telescope.builtin', 'live_grep{ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] }', 'Grep(Git Root)' )
-- luaMap('pn', 'telescope.builtin', 'live_grep{ cwd = "~/dev/notes" }',  'Grep(Notes)')
luaMap('pc', 'telescope.builtin', 'live_grep{ cwd = "~/dev/notes/creative-work/cheatsheets" }', 'Grep(Cheatsheets)')
luaMap('pl', 'telescope.builtin', 'live_grep{ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] .. "/libs" , glob_pattern = "' .. grepFilter .. '" }', 'Grep(Nx Libs)' )
-- luaMap('pL', 'telescope.builtin', 'find_files{ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] .. "/libs" , find_command = ' .. fileFilter .. ' }', 'Find File(Nx Libs)' )

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
leaderMap('pq', 'Telescope luasnip', 'LuaSnip (Q)')
  -- Nvim Tree
leaderMap("'", 'NvimTreeToggle', 'Explorer')

-- TMUX
leaderMap('m1', 'silent !tmux select-window -t 1', 'Switch Pane 1')
leaderMap('m2', 'silent !tmux select-window -t 2', 'Switch Pane 2')
leaderMap('m3', 'silent !tmux select-window -t 3', 'Switch Pane 3')
leaderMap('m4', 'silent !tmux select-window -t 4', 'Switch Pane 4')
leaderMap('m5', 'silent !tmux select-window -t 5', 'Switch Pane 5')
leaderMap('m6', 'silent !tmux select-window -t 6', 'Switch Pane 6')

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
leaderMap('v=', 'resize -2', '⬇️')
leaderMap('v-', 'resize +2', '⬆️')
-- leaderMap('\\', '<C-W>=', 'Balance')
-- leaderMap('|', '<C-W>|', 'Hide')

-- LSP
lspMap("gd", "lua vim.lsp.buf.definition()", "Definition")
lspMap("gD", "lua vim.lsp.buf.declaration()", "Declaration")
lspMap("gr", "lua vim.lsp.buf.references()", "References")
lspMap("gi", "lua vim.lsp.buf.implementation()", "Implementation")
category("gl", "+LSP Actions")
lspMap("gle", "lua vim.lsp.buf.hover()", "Hover")
lspMap("glw", "lua vim.lsp.buf.signature_help()", "Signature Popup")
lspMap("glr", "lua vim.lsp.buf.rename()", "Rename")
lspMap("glc", "lua vim.lsp.buf.code_action()", "Code Action")
leaderMap('is', "lua require('typescript').actions.addMissingImports({ sync = true }); require('typescript').actions.removeUnused(); vim.lsp.buf.format();", "Clean up - Format - Import")
lspMap("<C-p>", "lua vim.diagnostic.goto_next()", "Go to Next")
lspMap("<C-n>", "lua vim.diagnostic.goto_prev()", "Go to Previous")
-- { sync = true } is required because if import and format happen at the same time it shits its pants
vim.api.nvim_set_keymap("i", "<C-s>", "<cmd>lua require('typescript').actions.addMissingImports({ sync = true }); require('typescript').actions.removeUnused(); vim.lsp.buf.formatting_sync(nil, 1000); <CR>", opts)
vim.api.nvim_set_keymap("i", "<C-w>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
vim.api.nvim_set_keymap("i", "<C-e>", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)

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

