local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Styles
keymap("n", "<leader>oi", "<cmd>:lua require('nvim-quick-switcher').find('.+css|.+scss|.+sass', { regex = true, prefix='full' })<CR>", opts)

-- Types
keymap("n", "<leader>orm", "<cmd>:lua require('nvim-quick-switcher').find('.+model.ts|.+models.ts|.+types.ts', { regex = true })<CR>", opts)

-- Util
keymap("n", "<leader>ol", "<cmd>:lua require('nvim-quick-switcher').find('*util.*', { prefix = 'short' })<CR>", opts)

-- Tests
keymap("n", "<leader>ot", "<cmd>:lua require('nvim-quick-switcher').find('.+test|.+spec', { regex = true, prefix='full' })<CR>", opts)

-- Angular
keymap("n", "<leader>oy", "<cmd>:lua require('nvim-quick-switcher').find('.service.ts')<CR>", opts)
keymap("n", "<leader>ou", "<cmd>:lua require('nvim-quick-switcher').find('.component.ts')<CR>", opts)
keymap("n", "<leader>oo", "<cmd>:lua require('nvim-quick-switcher').find('.component.html')<CR>", opts)
keymap("n", "<leader>op", "<cmd>:lua require('nvim-quick-switcher').find('.module.ts')<CR>", opts)

-- SvelteKit
keymap("n", "<leader>oso", "<cmd>:lua require('nvim-quick-switcher').find('*page.svelte', { maxdepth = 1, ignore_prefix = true })<CR>", opts)
keymap("n", "<leader>osi", "<cmd>:lua require('nvim-quick-switcher').find('*layout.svelte', { maxdepth = 1, ignore_prefix = true })<CR>", opts)
keymap("n", "<leader>osu", "<cmd>:lua require('nvim-quick-switcher').find('.*page.server(.+js|.+ts)|.*page(.+js|.+ts)', { maxdepth = 1, regex = true, ignore_prefix = true })<CR>", opts)

 -- Inline TS
keymap("n", "<leader>osj", "<cmd>:lua require('nvim-quick-switcher').inline_ts_switch('svelte', '(script_element (end_tag) @capture)')<CR>", opts)
keymap("n", "<leader>osk", "<cmd>:lua require('nvim-quick-switcher').inline_ts_switch('svelte', '(style_element (start_tag) @capture)')<CR>", opts)

-- Redux-like
keymap("n", "<leader>ore", "<cmd>:lua require('nvim-quick-switcher').find('*effects.ts')<CR>", opts)
keymap("n", "<leader>ora", "<cmd>:lua require('nvim-quick-switcher').find('*actions.ts')<CR>", opts)
keymap("n", "<leader>orw", "<cmd>:lua require('nvim-quick-switcher').find('*store.ts')<CR>", opts)
keymap("n", "<leader>orf", "<cmd>:lua require('nvim-quick-switcher').find('*facade.ts')<CR>", opts)
keymap("n", "<leader>ors", "<cmd>:lua require('nvim-quick-switcher').find('.+query.ts|.+selectors.ts|.+selector.ts', { regex = true })<CR>", opts)
keymap("n", "<leader>orr", "<cmd>:lua require('nvim-quick-switcher').find('.+reducer.ts|.+repository.ts', { regex = true })<CR>", opts)

-- Test New Feature
-- Call print(vim.inspect(p)) to see what I return

local find_test_fn = [[function (p) local path = p.path; local file_name = p.prefix; local result = path:gsub('src', 'test') .. '/' .. file_name .. '*'; return result; end]]
local find_src_fn = [[function (p) local path = p.path; local file_name = p.prefix; local result = path:gsub('test', 'src') .. '/' .. file_name .. '*'; return result; end]]
keymap("n", "<leader>ojj", "<cmd>:lua require('nvim-quick-switcher').v2_find(" .. find_test_fn .. ")<CR>", opts)
keymap("n", "<leader>ojk", "<cmd>:lua require('nvim-quick-switcher').v2_find(" .. find_src_fn .. ")<CR>", opts)


-- These are just examples, the string function is hard to read.
-- And if you pass in with new lines it will break 
local ex_find_test_fn = function (p)
  local path = p.path;
  local file_name = p.prefix;
  local result = path:gsub('src', 'test') .. '/' .. file_name .. '*';
  return result;
end

local find_src_fn = function (p)
  local path = p.path;
  local file_name = p.prefix;
  local result = path:gsub('test', 'src') .. '/' .. file_name .. '*';
  return result;
end
