local map = vim.keymap.set
local hunk = require("config.hunk")
local terminal = require("config.terminal")
local inline = vim.g.pi_nvim_inline == true

map("n", "<Esc>", "<cmd>nohlsearch<cr>")
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
  map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
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
end

if not inline then
  map("n", "<leader>gh", hunk.open, { desc = "Open or focus Hunk review" })
  map("n", "<leader>gH", hunk.close, { desc = "Close Hunk terminal" })

  for i = 1, 4 do
    local index = i
    map("n", "<leader>t" .. index, function()
      terminal.toggle(index)
    end, { desc = "Terminal " .. index })
  end

  map("n", "<leader>tg", terminal.toggle_zmx, { desc = "Toggle zmx terminal" })
  map("n", "<leader>td", terminal.detach_zmx, { desc = "Detach zmx session" })
  map("n", "<leader>tf", terminal.send_file, { desc = "Send file path to zmx" })
  map("x", "<leader>ts", terminal.send_selection, { desc = "Send selection to zmx" })

  map("n", "<leader>at", terminal.send_this, { desc = "Send file position to zmx" })
  map("n", "<leader>af", terminal.send_file, { desc = "Send file path to zmx" })
  map("x", "<leader>av", terminal.send_selection, { desc = "Send selection to zmx" })
  map("n", "<leader>ap", terminal.prompt, { desc = "Prompt zmx terminal" })
end

vim.api.nvim_create_user_command("Wd", function(opts)
  require("mini.bufremove").delete(0, opts.bang)
end, {
  bang = true,
  desc = "Delete buffer without changing the window layout",
})

vim.cmd([[cnoreabbrev <expr> wd getcmdtype() ==# ':' && getcmdline() ==# 'wd' ? 'Wd' : 'wd']])

if not inline then
  vim.api.nvim_create_user_command("HunkMenu", hunk.menu, {
    desc = "Open the Hunk review menu",
  })

  vim.api.nvim_create_user_command("HunkClose", hunk.close, {
    desc = "Close the managed Hunk terminal",
  })

  vim.api.nvim_create_user_command("ZmxOpen", terminal.focus_zmx, {
    desc = "Open or focus the managed zmx terminal",
  })

  vim.api.nvim_create_user_command("ZmxDetach", terminal.detach_zmx, {
    desc = "Detach the current zmx session and return to the chooser",
  })

  vim.api.nvim_create_user_command("ZmxPrompt", terminal.prompt, {
    desc = "Prompt the managed zmx terminal",
  })

  vim.api.nvim_create_user_command("ZmxThis", terminal.send_this, {
    desc = "Send current file position to zmx",
  })

  vim.api.nvim_create_user_command("ZmxFile", terminal.send_file, {
    desc = "Send current file path to zmx",
  })

  vim.api.nvim_create_user_command("ZmxSend", function(opts)
    terminal.send_range(opts.line1, opts.line2)
  end, {
    range = true,
    desc = "Send the current line or range to zmx",
  })
end
