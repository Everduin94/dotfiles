local map = vim.keymap.set
local hunk = require("config.hunk")
local terminal = require("config.terminal")
local inline = vim.g.pi_nvim_inline == true

map("n", "<Esc>", "<cmd>nohlsearch<cr>")
-- <Esc> leaves terminal mode (was for escaping pi running in an nvim terminal)
-- map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("n", "gV", '"g`[" . strpart(getregtype(), 0, 1) . "g`]"', {
  expr = true,
  replace_keycodes = false,
  desc = "Select last changed or yanked text",
})
map("x", "g/", [[<Esc>/\%V]], { silent = false, desc = "Search inside selection" })

for _, mode in ipairs({ "n", "x", "o" }) do
  map(mode, "H", "^", { desc = "Beginning of line" })
  map(mode, "L", "$", { desc = "End of line" })
end

map("n", "<leader>-", "<C-w>s", { desc = "Split window below" })
map("n", "<leader>|", "<C-w>v", { desc = "Split window right" })

map("n", "<leader>pg", function()
  local name = vim.fn.expand("%:t")
  if name == "" then
    vim.notify("Current buffer has no file", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", name)
  vim.notify("Copied: " .. name)
end, { desc = "Copy buffer filename" })

if not inline then
  map("n", "-", function()
    require("config.oil").open_panel()
  end, { desc = "Oil side panel (left)" })
  map("n", "<leader><space>", function()
    require("config.pick").files()
  end, { desc = "Find files" })
  map("n", "<leader>/", function()
    require("config.pick").grep()
  end, { desc = "Grep project" })
  map("n", "<leader>e", function()
    require("oil").toggle_float()
  end, { desc = "Toggle explorer" })
end

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "<C-s>", "<cmd>write<cr>", { desc = "Write buffer" })
map("n", "<leader>ww", "<cmd>write<cr>", { desc = "Write buffer" })
map("n", "<leader>wd", "<cmd>close<cr>", { desc = "Close window (keeps buffer)" })
local function repeatable_resize(feed_keys)
  return function()
    _G.__win_resize_last = function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(feed_keys, true, false, true), "n", false)
    end
    vim.o.operatorfunc = "v:lua.__win_resize_op"
    return "g@l"
  end
end

function _G.__win_resize_op()
  if _G.__win_resize_last then
    _G.__win_resize_last()
  end
end

map("n", "<leader>w=", "<C-w>=", { desc = "Equalize window sizes" })
map("n", "<leader>w-", repeatable_resize("<C-w>-"), { expr = true, desc = "Decrease window height (repeat with .)" })
map("n", "<leader>w+", repeatable_resize("<C-w>+"), { expr = true, desc = "Increase window height (repeat with .)" })
map("n", "<leader>w<", repeatable_resize("<C-w><"), { expr = true, desc = "Decrease window width (repeat with .)" })
map("n", "<leader>w>", repeatable_resize("<C-w>>"), { expr = true, desc = "Increase window width (repeat with .)" })
map("n", "<leader>qq", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<leader>qa", "<cmd>xall<cr>", { desc = "Save all and quit" })
map("n", "<leader>od", "<cmd>e#<cr>", { desc = "Alternate file" })

if not inline then
  map("n", "<leader>0", "<cmd>Grapple tag<cr>", { desc = "Grapple tag file" })
  map("n", "<leader>h", "<cmd>Grapple toggle_tags<cr>", { desc = "Grapple tags" })

  for i = 1, 5 do
    map("n", "<leader>" .. i, string.format("<cmd>Grapple select index=%d<cr>", i), {
      desc = "Grapple to file " .. i,
    })
  end
end

map("n", "<leader>ms", function()
  vim.cmd.startinsert()
  vim.schedule(function()
    require("config.snippets").pick()
  end)
end, { desc = "Snippet picker" })

if not inline then
  map("n", "<leader>gd", function()
    MiniDiff.toggle_overlay()
  end, { desc = "Git diff overlay" })

  map("n", "<leader>cR", "<cmd>LspRestart<cr>", { desc = "LSP restart (buffer)" })
  map("n", "<leader>cA", "<cmd>LspRestart!<cr>", { desc = "LSP restart (all clients)" })

  map("n", "<leader>ss", function()
    require("config.sessions").write()
  end, { desc = "Save session for this directory" })
  map("n", "<leader>sl", function()
    require("config.sessions").select()
  end, { desc = "Load a session" })
end

if not inline then
  map("n", "<leader>gh", hunk.open, { desc = "Open or focus Hunk review" })
  map("n", "<leader>gH", hunk.close, { desc = "Close Hunk terminal" })

  for i = 1, 4 do
    local index = i
    map("n", "<leader>t" .. index, function()
      terminal.open(index)
    end, { desc = "Terminal " .. index .. " (right split)" })
  end
end

vim.api.nvim_create_user_command("Wd", function(opts)
  require("mini.bufremove").delete(0, opts.bang)
end, {
  bang = true,
  desc = "Delete buffer without changing the window layout",
})

vim.cmd([[cnoreabbrev <expr> wd getcmdtype() ==# ':' && getcmdline() ==# 'wd' ? 'Wd' : 'wd']])

-- Recenter (zz) after big jumps. Uncomment the ones you want.
-- local function centered(lhs, rhs, desc, mode)
--   map(mode or "n", lhs, rhs .. "zz", { desc = desc .. " (centered)" })
-- end
-- centered("<C-d>", "<C-d>", "Half page down")
-- centered("<C-u>", "<C-u>", "Half page up")
-- centered("<C-f>", "<C-f>", "Page down")
-- centered("<C-b>", "<C-b>", "Page up")
-- centered("n", "nzv", "Next match")
-- centered("N", "Nzv", "Previous match")
-- centered("*", "*zv", "Search word forward")
-- centered("#", "#zv", "Search word backward")
-- centered("G", "G", "Go to last line")
-- centered("{", "{", "Previous paragraph")
-- centered("}", "}", "Next paragraph")
-- centered("%", "%", "Matching pair")
-- centered("<C-o>", "<C-o>", "Jump back")
-- centered("<C-i>", "<C-i>", "Jump forward") -- <C-i> is <Tab> (sub-mode) in most terminals
-- centered("g;", "g;", "Older change")
-- centered("g,", "g,", "Newer change")
-- centered("]s", "]s", "Next misspelling")
-- centered("[s", "[s", "Previous misspelling")
-- -- functions can't take a zz suffix, so center after they run:
-- local function then_center(fn)
--   return function()
--     fn()
--     vim.schedule(function()
--       vim.cmd.normal({ "zz", bang = true })
--     end)
--   end
-- end
-- map("n", "]d", then_center(function() vim.diagnostic.jump({ count = 1, float = true }) end), { desc = "Next diagnostic (centered)" })
-- map("n", "[d", then_center(function() vim.diagnostic.jump({ count = -1, float = true }) end), { desc = "Previous diagnostic (centered)" })
-- -- gd is set in autocmds.lua (LspAttach): then_center(vim.lsp.buf.definition)

if not inline then
  vim.api.nvim_create_user_command("HunkMenu", hunk.menu, {
    desc = "Open the Hunk review menu",
  })

  vim.api.nvim_create_user_command("HunkClose", hunk.close, {
    desc = "Close the managed Hunk terminal",
  })
end
