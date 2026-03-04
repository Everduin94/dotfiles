require("config/generators/features/svelte-feature-folder")

local ls = require("luasnip")

-- Deprecated: No longer used.
function _G.nexpand(body)
  vim.api.nvim_feedkeys("o", "n", true) -- open new line below and enter insert mode
  vim.defer_fn(function()
    if type(body) == "string" then
      ls.snip_expand(ls.parser.parse_snippet("anon", body))
    else
      ls.snip_expand(body)
    end
  end, 10)
end

vim.keymap.set({ "i", "s" }, "<C-d>", function()
  if ls.jumpable(1) then
    return "<Cmd>lua require('luasnip').jump(1)<CR>"
  end
  if vim.snippet.active({ direction = 1 }) then
    return "<Cmd>lua vim.snippet.jump(1)<CR>"
  else
    return "<Tab>"
  end
end, { expr = true })

-- TODO: Move to snippet-utils
local function expand_snippet(body)
  if type(body) == "string" then
    ls.snip_expand(ls.parser.parse_snippet("anon", body))
  else
    ls.snip_expand(body)
  end
end

-- TODO: Move to snippet-utils
local function show_snippet_menu()
  local ft = vim.bo.filetype
  local snippets = ls.get_snippets(ft) or {}
  local names = {}
  for _, snip in ipairs(snippets) do
    table.insert(names, snip.name .. " (" .. snip.trigger .. ")")
  end

  if #names == 0 then
    print("No snippets for filetype: " .. ft)
    return
  end

  vim.schedule(function()
    vim.ui.select(names, { prompt = "Select snippet:" }, function(choice)
      if not choice then
        return
      end

      -- find the snippet object
      local snip
      for _, s in ipairs(snippets) do
        if s.name .. " (" .. s.trigger .. ")" == choice then
          snip = s
          break
        end
      end

      if snip then
        expand_snippet(snip.body or snip)
      end
    end)
  end)
end

vim.keymap.set({ "i" }, "<C-f>", function()
  require("copilot.suggestion").accept()
end, { noremap = true, silent = true })

vim.keymap.set({ "n" }, "<leader>ms", function()
  show_snippet_menu()
end, { noremap = true, silent = true })

vim.keymap.set({ "i", "s", "v" }, "<C-s>", function()
  local mode = vim.api.nvim_get_mode().mode

  -- From: https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#selection
  -- In most cases you just use cut_selection_keys
  -- However, we already had a insert mode binding to open snippets.
  -- So we had to use the manual approach. (Setting cut_selection_keys to <C-s> did not work)
  if mode == "v" or mode == "V" or mode == "\22" then -- \22 is <C-v> (visual block)
    vim.cmd("normal! \27") -- ESC
    vim.schedule(function()
      require("luasnip.util.select").pre_yank("z")
      vim.cmd('normal! gv"zy') -- Re-select and yank to register z
      vim.cmd("normal! gvd") -- Re-select and delete
      require("luasnip.util.select").post_yank("z")

      vim.schedule(function()
        show_snippet_menu()
      end)
    end)

    return
  end

  show_snippet_menu()
end, { noremap = true, silent = true })

local map = LazyVim.safe_keymap_set
-- Stop gaps
map("n", "H", "^", { desc = "Beginning of Line" })
map("v", "H", "^", { desc = "Beginning of Line" })
map("o", "H", "^", { desc = "Beginning of Line" })
map("n", "L", "$", { desc = "End of Line" })
map("v", "L", "$", { desc = "End of Line" })
map("o", "L", "$", { desc = "End of Line" })

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

-- Terminal
local run_dev = require("toggleterm.terminal").Terminal:new({
  cmd = "npm run dev",
  direction = "horizontal",
  close_on_exit = false,
})

local anything_term = require("toggleterm.terminal").Terminal:new({
  direction = "horizontal",
  close_on_exit = false,
})

map("n", "<leader>t1", function()
  run_dev:toggle()
end)
map("n", "<leader>t2", function()
  require("sidekick.cli").toggle({ name = "opencode", focus = true })
end)

-- Give all the options, see what we like
map("n", "<leader>t3", function()
  anything_term:toggle(nil, "horizontal")
end)
map("n", "<leader>t4", function()
  anything_term:toggle(nil, "float")
end)
map("n", "<leader>tg", function()
  anything_term:toggle(nil, "tab")
end)

map("n", "<leader>th", function()
  run_dev:close()
  anything_term:close()
  require("sidekick.cli").hide()
end)
map("n", "<leader>tx", function()
  run_dev:shutdown()
end)

map("n", "<leader>t0", function()
  run_dev:toggle()
  require("sidekick.cli").toggle({ name = "opencode", focus = true })
end)

-- Misc
map("n", "<leader>od", "<cmd>e#<cr>", { desc = "Alternate" })

vim.keymap.set("i", "<C-l>", function()
  require("copilot.suggestion").accept()
end, { desc = "Copilot Accept" })
