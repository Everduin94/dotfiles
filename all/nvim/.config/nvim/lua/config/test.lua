local M = {}

-- Neotest's watch consumer finds a test's dependencies by parsing the file for
-- "symbols" and asking LSP for their definitions. Zig is not in neotest's
-- default symbol set, so watch used to die with "No symbols query for language:
-- zig" and never re-run anything.
local zig_symbol_query = [[
;query
(call_expression function: (identifier) @symbol)
(call_expression function: (field_expression member: (identifier) @symbol))
]]

-- The symbol parsing itself happens in a child Nvim that neotest starts with
-- `-u NONE`, so it only sees neotest's *default* queries. Teach that child our
-- query too (it starts asynchronously, hence the retries).
local push_zig_symbol_query = "(function(q) require('neotest.config').watch.symbol_queries.zig = q return true end)"

function M.setup()
  local neotest = require("neotest")

  neotest.setup({
    adapters = {
      -- Own Zig 0.16 adapter (lawrence-laz/neotest-zig only supports <= 0.14).
      require("neotest-zig-build"),
    },
    discovery = { enabled = false }, -- only parse test files on demand
    watch = { symbol_queries = { zig = zig_symbol_query } },
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

  local nio = require("nio")
  local function sync_symbol_queries(attempt)
    nio.run(function()
      local subprocess = require("neotest.lib.subprocess")
      if subprocess.enabled() and pcall(subprocess.call, push_zig_symbol_query, { zig_symbol_query }) then
        return
      end
      if attempt < 25 then
        vim.defer_fn(function()
          sync_symbol_queries(attempt + 1)
        end, 200)
      end
    end)
  end
  sync_symbol_queries(1)

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
