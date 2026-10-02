local M = {}

function M.setup()
  local neotest = require("neotest")

  neotest.setup({
    adapters = {
      -- Own Zig 0.16 adapter (lawrence-laz/neotest-zig only supports <= 0.14).
      require("neotest-zig-build"),
    },
    discovery = { enabled = false }, -- only parse test files on demand
    output = { open_on_run = false },
    quickfix = { enabled = false, open = false },
    status = { virtual_text = true, signs = true },
    summary = { animated = false },
    floating = {
      border = "rounded",
      max_height = 0.8,
      max_width = 0.8,
      -- window options applied to neotest floats (output). Floats have no
      -- `padding`: `scrolloff` is the closest thing (blank lines top/bottom
      -- while scrolling), winblend/winhighlight only recolour the frame.
      options = { scrolloff = 2, winblend = 0 },
    },
  })

  -- `<Esc>` / `q` close neotest's window (output float, summary, output panel).
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "neotest-output", "neotest-summary", "neotest-output-panel" },
    callback = function(ev)
      for _, lhs in ipairs({ "<Esc>", "q" }) do
        vim.keymap.set("n", lhs, "<cmd>close<cr>", { buffer = ev.buf, desc = "Close neotest window" })
      end
    end,
  })

  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { desc = desc })
  end

  map("<leader>rr", function()
    neotest.run.run()
  end, "Run nearest test")
  map("<leader>rf", function()
    neotest.run.run(vim.fn.expand("%"))
  end, "Run tests in file")
  map("<leader>rl", function()
    neotest.run.run_last()
  end, "Run last test")
  map("<leader>rx", function()
    neotest.run.stop()
  end, "Stop test run")
  map("<leader>ro", function()
    -- toggle: pressing it while inside the output float closes it
    if vim.bo.filetype == "neotest-output" then
      vim.cmd("close")
      return
    end
    neotest.output.open({ enter = true, short = false })
  end, "Test output (float)")
  map("<leader>rO", function()
    neotest.output_panel.toggle()
  end, "Test output panel")
  map("<leader>rs", function()
    neotest.summary.toggle()
  end, "Test summary")
end

return M
