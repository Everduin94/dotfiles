-- Host side of pi's <C-g> "external editor" when pi runs inside a Neovim terminal.
--
-- Flow:
--   1. terminal buffer `<C-g>` -> M.forward(): stamp this server + forward ^G to pi.
--   2. pi runs $EDITOR (bin/pi-nvim-edit FILE) inside the terminal.
--   3. pi-nvim-edit reads the fresh stamp and calls M.open(FILE, DONE) over RPC.
--   4. A float opens here; when it closes we touch DONE and pi-nvim-edit exits.
-- Without a fresh stamp (pi in a plain terminal) pi-nvim-edit falls back to an
-- inline nvim.
local M = {}

local stamp_file = vim.fn.stdpath("state") .. "/pi-edit-host"

function M.stamp()
  pcall(vim.fn.mkdir, vim.fn.fnamemodify(stamp_file, ":h"), "p")
  pcall(vim.fn.writefile, { vim.v.servername .. "\t" .. os.time() }, stamp_file)
end

--- Terminal-mode `<C-g>`: stamp, then pass ^G through to the job.
function M.forward()
  M.stamp()
  local chan = vim.b.terminal_job_id
  if chan then
    vim.api.nvim_chan_send(chan, "\7")
  end
end

local function signal_done(done)
  if done and done ~= "" then
    pcall(vim.fn.writefile, { "done" }, done)
  end
end

function M.open(file, done)
  local origin_win = vim.api.nvim_get_current_win()
  local origin_buf = vim.api.nvim_get_current_buf()
  local was_terminal = vim.bo[origin_buf].buftype == "terminal"

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.7)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " pi prompt  (:wq / <C-s> save+send, :q! discard) ",
    title_pos = "center",
  })

  vim.cmd.edit(vim.fn.fnameescape(file))
  local edit_buf = vim.api.nvim_get_current_buf()
  vim.bo[edit_buf].bufhidden = "wipe"
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].number = false
  vim.wo[win].signcolumn = "no"
  vim.b[edit_buf].minidiff_disable = true

  vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>silent! write | close<cr>", {
    buffer = edit_buf,
    desc = "Save and send to pi",
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    once = true,
    callback = function()
      signal_done(done)
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(origin_win) then
          vim.api.nvim_set_current_win(origin_win)
          if was_terminal then
            vim.cmd.startinsert()
          end
        end
      end)
    end,
  })

  vim.schedule(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.cmd.startinsert()
    end
  end)
  return 1
end

return M
