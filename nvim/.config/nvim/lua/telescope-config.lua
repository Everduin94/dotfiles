local actions = require("telescope.actions")
require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    path_display = {'shorten'},
    mappings = {
      i = {
        ["<esc>"] = actions.close
      },
      -- i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        -- ["<C-h>"] = "which_key"
      -- }
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}

require('telescope').load_extension('fzf')
require('telescope').load_extension('dap')

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
keymap("n", "<leader>pp", "<cmd>lua require('telescope.builtin').find_files()<cr>", opts)
keymap("n", "<leader>ph", "<cmd>lua require('telescope.builtin').highlights()<cr>", opts)
keymap("n", "<leader>pf", "<cmd>lua require('telescope.builtin').live_grep()<cr>", opts)
keymap("n", "<leader>pb", "<cmd>lua require('telescope.builtin').buffers()<cr>", opts)
keymap("n", "<leader>p*", "<cmd>lua require('telescope.builtin').grep_string()<cr>", opts)
keymap("n", "<leader>po", "<cmd>lua require('telescope.builtin').find_files({ cwd = vim.fn.systemlist('git rev-parse --show-toplevel')[1] })<cr>", opts)
keymap("n", "<leader>pg", "<cmd>lua require('telescope.builtin').live_grep{ cwd = vim.fn.systemlist('git rev-parse --show-toplevel')[1] }<cr>", opts)



