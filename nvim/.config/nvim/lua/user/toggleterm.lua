local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
	return
end

toggleterm.setup({
	size = 12,
	open_mapping = [[<c-\>]],
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 2,
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	direction = "horizontal",
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
		border = "curved",
		winblend = 0,
		highlights = {
			border = "Normal",
			background = "Normal",
		},
	},
})

function _G.set_terminal_keymaps()
  local opts = {noremap = true}
  vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

local Terminal = require("toggleterm.terminal").Terminal

local node = Terminal:new({ cmd = "node", hidden = true })

function _NODE_TOGGLE()
	node:toggle()
end


local jest = Terminal:new({ cmd = "jest", hidden = true })

function _JEST_TOGGLE()
	jest:toggle()
end

local gitPush = Terminal:new({ cmd = "l push", hidden = true })

function _GIT_PUSH_TOGGLE()
	gitPush:toggle()
end

local cwd = Terminal:new({ hidden = false, count=1 })
function _CWD_TOGGLE()
    local path = vim.api.nvim_buf_get_name(0):match("^(.+)/.+$")
    cwd:toggle()
    -- Learning
      -- change_dir, doesn't work because cwd.dir ~= dir
      -- Why? Because dir is always the vim cwd. So if you go to init.lua, it thinks the paths match.
      -- i.e. it doesn't look at where the terminal really is, just where it was defined
    if cwd:is_open() then
      -- To clear
        -- cwd:send({'cd ' .. path, 'clear' }, false)
      cwd:send('cd ' .. path, false)
    end
end

-- TODO (03/26/2022 - 07:24pm): Make lua scripts available in nvim
local function getcwd()
 local pipe = assert(io.popen('pwd'))
 local path = assert(pipe:read('*l'))
 pipe:close()
 return path
end

local function isCxCloud()
  local pwd = getcwd()
  return string.find(pwd, 'cx%-cloud%-ui')
end

local project = isCxCloud() and 'cx-portal' or ''
local ng_serve = Terminal:new({ cmd = "ng serve", hidden = true })
function _NG_SERVE_TOGGLE()
	ng_serve:toggle()
end
