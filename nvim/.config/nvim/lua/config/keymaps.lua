-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local sv = require("config/snippet-values")

function _G.nexpand(body)
  vim.api.nvim_feedkeys("o", "n", true)
  vim.defer_fn(function()
    vim.snippet.expand(body)
  end, 10)
end

vim.keymap.set({ "i", "s" }, "<C-d>", function()
  if vim.snippet.active({ direction = 1 }) then
    return "<Cmd>lua vim.snippet.jump(1)<CR>"
  else
    return "<Tab>"
  end
end, { expr = true })

local map = LazyVim.safe_keymap_set
-- Stop gaps
map("n", "H", "^", { desc = "Beginning of Line" })
map("v", "H", "^", { desc = "Beginning of Line" })
map("o", "H", "^", { desc = "Beginning of Line" })
map("n", "L", "$", { desc = "End of Line" })
map("v", "L", "$", { desc = "End of Line" })
map("o", "L", "$", { desc = "End of Line" })

local function map_snippet_which_key(tbl, func)
  local new_tbl = {}
  for _, v in pairs(tbl) do
    table.insert(new_tbl, func(v))
  end
  return new_tbl
end

-- Define the transformation function
local function snippet_to_which_key(snippet)
  return {
    snippet.key,
    function()
      nexpand(snippet.body)
    end,
    desc = snippet.desc,
    icon = snippet.icon,
  }
end

local function which_key_snippets()
  return map_snippet_which_key(sv, snippet_to_which_key)
end

local wk = require("which-key")
wk.add(which_key_snippets())
wk.add({
  { "<leader>ms", group = "Svelte", icon = { icon = "", color = "orange" } },
})

map("n", "<leader>su", function()
  vim.snippet.expand("var ${1:name} ${2:type} $0")
end, { desc = "testing snippets" })
map("n", "<leader>gu", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview Hunk" })
map("t", [[<C-\>]], [[<C-\><C-n>]], { desc = "Escape Terminal" })
map("t", [[<esc>]], [[<C-\><C-n>]], { desc = "Escape Terminal" })

-- Karabiner speed hack
map("i", "<C-l>", "<esc>l")
map("i", "<C-p>", "<esc>p")
map("i", "<C-o>", "<esc>o")
map("i", "<C-k>", "<esc>k")
map("i", "<C-j>", "<esc>j")
map("i", "<C-h>", "<esc>h")

map("n", "<leader>co", "<cmd>copen<cr>", { desc = "Open Quick Fix" })
map("n", "<leader>cl", "<cmd>cclose<cr>", { desc = "Close Quick Fix" })

-- Windows
map("n", "<A-k>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<A-j>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<A-l>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<A-h>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Tabs
map("n", "<leader><tab>r", ":LualineRenameTab<space>", { desc = "Rename Tab" })

-- Harpoon
local harpoon = require("harpoon")
map("n", "<leader>t1", function()
  harpoon:list("term"):select(1)
end)
map("n", "<leader>t2", function()
  harpoon:list("term"):select(2)
end)
map("n", "<leader>t3", function()
  harpoon:list("term"):select(3)
end)
map("n", "<leader>t4", function()
  harpoon:list("term"):select(4)
end)

-- Misc
map("n", "<leader>od", "<cmd>e#<cr>", { desc = "Alternate" })
