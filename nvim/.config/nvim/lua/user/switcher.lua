local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
keymap("n", "<leader>ou", "<cmd>:lua require('nvim-quick-switcher').switch('component.ts')<CR>", opts)
keymap("n", "<leader>oi", "<cmd>:lua require('nvim-quick-switcher').switch('component.scss')<CR>", opts)
keymap("n", "<leader>oo", "<cmd>:lua require('nvim-quick-switcher').switch('component.html')<CR>", opts)
keymap("n", "<leader>op", "<cmd>:lua require('nvim-quick-switcher').switch('module.ts')<CR>", opts)
keymap("n", "<leader>os", "<cmd>:lua require('nvim-quick-switcher').switch('service.ts')<CR>", opts)
keymap("n", "<leader>ot", "<cmd>:lua require('nvim-quick-switcher').switch('component.spec.ts')<CR>", opts)
keymap("n", "<leader>ort", "<cmd>:lua require('nvim-quick-switcher').switch('spec.ts')<CR>", opts)
keymap("n", "<leader>oru", "<cmd>:lua require('nvim-quick-switcher').switch('store.ts')<CR>", opts)
keymap("n", "<leader>ori", "<cmd>:lua require('nvim-quick-switcher').switch('effects.ts')<CR>", opts)
keymap("n", "<leader>oro", "<cmd>:lua require('nvim-quick-switcher').switch('query.ts')<CR>", opts)
keymap("n", "<leader>orp", "<cmd>:lua require('nvim-quick-switcher').switch('actions.ts')<CR>", opts)
keymap("n", "<leader>ovu", "<cmd>:lua require('nvim-quick-switcher').switch('component.ts', { split = 'vertical' })<CR>", opts)
keymap("n", "<leader>ovi", "<cmd>:lua require('nvim-quick-switcher').switch('component.scss', { split = 'vertical' })<CR>", opts)
keymap("n", "<leader>ovo", "<cmd>:lua require('nvim-quick-switcher').switch('component.html', { split = 'vertical' })<CR>", opts)
keymap("n", "<leader>oc", "<cmd>:lua require('nvim-quick-switcher').toggle('cpp', 'h')<CR>", opts)

