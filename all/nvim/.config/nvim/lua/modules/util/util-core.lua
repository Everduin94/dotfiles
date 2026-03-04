local M = {}

M.autopair = {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
}

M.oil = {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependencies
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}

M.autolist = {
  "gaoDean/autolist.nvim",
  ft = {
    "markdown",
    "text",
    "tex",
    "plaintex",
    "norg",
  },
  config = function()
    require("autolist").setup()

    vim.keymap.set("i", "<tab>", "<cmd>AutolistTab<cr>")
    vim.keymap.set("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>")
    -- vim.keymap.set("i", "<c-t>", "<c-t><cmd>AutolistRecalculate<cr>") -- an example of using <c-t> to indent
    vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
    vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>")
    vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
    vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>")
    vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<cr>")

    -- cycle list types with dot-repeat
    vim.keymap.set("n", "<leader>cn", require("autolist").cycle_next_dr, { expr = true })
    vim.keymap.set("n", "<leader>cp", require("autolist").cycle_prev_dr, { expr = true })

    -- functions to recalculate list on edit
    vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>")
    vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>")
    vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>")
    vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>")
  end,
}

M.toggleterm = {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("modules.util.util-commands")
  end,
}

M.gitdiff = { "sindrets/diffview.nvim" }

M.octo = {
  "pwntester/octo.nvim",
  cmd = "Octo",
  opts = {
    -- or "fzf-lua" or "snacks" or "default"
    picker = "snacks",
    -- bare Octo command opens picker of commands
    enable_builtin = true,
  },
  keys = {
    {
      "<leader>g-",
      function()
        -- I think we could prefix or use some naming conventions here to be more clear on is this an action, a search, specific to review, etc...
        local items = {
          { label = "List coworker PRs for review", fn = list_coworker_prs },
          { label = "Create a new PR for this branch", cmd = "Octo pr create" },
          { label = "Edit this PR description", cmd = "Octo pr edit" },
          { label = "Mark this PR as draft", cmd = "Octo pr draft" },
          { label = "Mark this PR as ready", cmd = "Octo pr ready" },
          { label = "Get all PR checks", cmd = "Octo pr checks" },
          { label = "Checkout PR", cmd = "Octo pr checkout" },
          { label = "List all PR commits", cmd = "Octo pr commits" },
          { label = "List all PR changes", cmd = "Octo pr changes" },
          { label = "Squash and merge this PR", cmd = "Octo pr merge squash delete" },
          { label = "Resolve this thread", cmd = "Octo thread resolve" },
          { label = "List all of MY open PRs", cmd = "Octo search is:pr is:open author:everduin94" },
          { label = "Add comment", cmd = "Octo comment add" },
          { label = "Reply to this comment", cmd = "Octo comment reply" },
          { label = "React thumbs up to this comment", cmd = "Octo reaction thumbs_up" },
          { label = "Reload PR", cmd = "Octo pr reload" },
          { label = "Copy PR URL", cmd = "Octo pr url" },
          { label = "Start review of this PR", cmd = "Octo review start" },
          { label = "Submit review for this PR", cmd = "Octo review submit" },
          { label = "Resume review for this PR", cmd = "Octo review resume" },
          { label = "Discard review for this PR", cmd = "Octo review discard" },
          { label = "List all review comments", cmd = "Octo review comments" },
          { label = "Review one specific commit", cmd = "Octo review commit" },
          { label = "Close review", cmd = "Octo review close" },
        }
        vim.ui.select(items, {
          prompt = "Octo",
          format_item = function(item)
            return item.label
          end,
        }, function(choice)
          if choice then
            if choice.fn then
              choice.fn()
            else
              vim.cmd(choice.cmd)
            end
          end
        end)
      end,
      desc = "Github",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
  },
}

M.codediff = {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  keys = {
    {
      "<leader>g0",
      function()
        local items = {
          { label = "All pull request", cmd = "CodeDiff main..." },
          { label = "File vs branch", cmd = "CodeDiff file main..." },
          { label = "File current changes", cmd = "CodeDiff file HEAD" },
          { label = "File vs last commit", cmd = "CodeDiff file HEAD~1" },
          { label = "All current changes", cmd = "CodeDiff HEAD" },
          { label = "All vs last commit", cmd = "CodeDiff HEAD~1" },
        }
        vim.ui.select(items, {
          prompt = "CodeDiff",
          format_item = function(item)
            return item.label
          end,
        }, function(choice)
          if choice then
            vim.cmd(choice.cmd)
          end
        end)
      end,
      desc = "CodeDiff",
    },
    -- I don't think this is working.
    {
      "<tab>",
      function()
        local cd = require("codediff")
        if cd.next_hunk() == false then
          cd.next_file()
        end
      end,
      desc = "Next hunk or file",
      -- ft = -- would need to scope this to codediff buffers
    },
  },
}

return M
