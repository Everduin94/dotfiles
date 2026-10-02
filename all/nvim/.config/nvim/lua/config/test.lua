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
