local map = vim.keymap.set
local hunk = require("config.hunk")
local tmux = require("config.tmux")
local inline = vim.g.pi_nvim_inline == true

map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "gV", '"g`[" . strpart(getregtype(), 0, 1) . "g`]"', {
  expr = true,
  replace_keycodes = false,
  desc = "Select last changed or yanked text",
})
map("x", "g/", [[<Esc>/\%V]], { silent = false, desc = "Search inside selection" })

if not inline then
  map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
  map("n", "<leader><space>", function()
    require("config.pick").files()
  end, { desc = "Find files" })
  map("n", "<leader>/", function()
    require("config.pick").grep()
  end, { desc = "Grep project" })
  map("n", "<leader>e", "<cmd>Oil --float<cr>", { desc = "Open explorer" })
end

map("n", "<C-h>", function()
  tmux.navigate("h", "-L")
end, { desc = "Window or tmux left" })

map("n", "<C-j>", function()
  tmux.navigate("j", "-D")
end, { desc = "Window or tmux down" })

map("n", "<C-k>", function()
  tmux.navigate("k", "-U")
end, { desc = "Window or tmux up" })

map("n", "<C-l>", function()
  tmux.navigate("l", "-R")
end, { desc = "Window or tmux right" })

map("n", "<C-n>", tmux.next_window, { desc = "Next tmux window" })
map("n", "<C-p>", tmux.previous_window, { desc = "Previous tmux window" })

map("n", "<C-s>", "<cmd>write<cr>", { desc = "Write buffer" })
map("n", "<C-q>", "<cmd>xall<cr>", { desc = "Save all and quit" })
map("n", "<leader>ww", "<cmd>write<cr>", { desc = "Write buffer" })
map("n", "<leader>qq", "<cmd>quit<cr>", { desc = "Quit window" })

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

map("n", "<leader>gh", hunk.open, { desc = "Open or focus Hunk review" })
map("n", "<leader>gH", hunk.close, { desc = "Close Hunk pane" })

map("n", "<leader>tt", tmux.shell, { desc = "Open tmux shell pane" })

map("n", "<leader>aa", tmux.open, { desc = "Open pi pane" })
map("n", "<leader>as", tmux.attach, { desc = "Attach pi pane" })
map("n", "<leader>ad", tmux.close, { desc = "Close pi pane" })
map("n", "<leader>at", tmux.send_this, { desc = "Send file position to pi" })
map("n", "<leader>af", tmux.send_file, { desc = "Send file path to pi" })
map("x", "<leader>av", tmux.send_selection, { desc = "Send selection to pi" })
map("n", "<leader>ap", tmux.prompt, { desc = "Prompt pi" })

vim.api.nvim_create_user_command("HunkMenu", hunk.menu, {
  desc = "Open the Hunk review menu",
})

vim.api.nvim_create_user_command("HunkClose", hunk.close, {
  desc = "Close the managed Hunk pane",
})

vim.api.nvim_create_user_command("TmuxShell", tmux.shell, {
  desc = "Open a tmux split with a shell",
})

vim.api.nvim_create_user_command("PiOpen", tmux.open, {
  desc = "Open a tmux split running pi",
})

vim.api.nvim_create_user_command("PiAttach", tmux.attach, {
  desc = "Attach to an existing tmux pane running pi",
})

vim.api.nvim_create_user_command("PiClose", tmux.close, {
  desc = "Close the managed pi tmux pane",
})

vim.api.nvim_create_user_command("PiTarget", function(opts)
  tmux.set_target(opts.args)
end, {
  nargs = 1,
  desc = "Set the tmux pane id used for pi commands",
})

vim.api.nvim_create_user_command("PiPrompt", tmux.prompt, {
  desc = "Prompt pi in tmux",
})

vim.api.nvim_create_user_command("PiThis", tmux.send_this, {
  desc = "Send current file position to pi",
})

vim.api.nvim_create_user_command("PiFile", tmux.send_file, {
  desc = "Send current file path to pi",
})

vim.api.nvim_create_user_command("PiFocus", tmux.focus_target, {
  desc = "Focus the pi tmux pane",
})

vim.api.nvim_create_user_command("PiSend", function(opts)
  tmux.send_range(opts.line1, opts.line2)
end, {
  range = true,
  desc = "Send the current line or range to pi",
})
