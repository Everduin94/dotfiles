local M = {}
local util = require("modules.ai.ai-util")

vim.api.nvim_create_user_command("RunPythonTask", util.run_python_task, {})
vim.api.nvim_create_user_command("StopPythonTask", util.stop_python_task, {})

vim.keymap.set("n", "<leader>rp", "<cmd>RunPythonTask<cr>", { desc = "Run Python Task" })
vim.keymap.set("n", "<leader>ro", "<cmd>CodeCompanionChat<cr>", { desc = "Start new AI Chat" })
vim.keymap.set("v", "<leader>ro", ":CodeCompanion ", { desc = "Start new AI assistant" })
vim.keymap.set("n", "<leader>re", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle existing AI Chat" })

vim.keymap.set("n", "<leader>rc", function()
  require("copilot.suggestion").toggle_auto_trigger()
  -- Log copilot on / off
  print(vim.b.copilot_suggestion_auto_trigger and "Copilot suggestions: ON" or "Copilot suggestions: OFF")
end, { desc = "Toggle Copilot suggestions" })

M.sidekick_keys = {
  {
    "<leader>ac",
    function()
      -- if there is a next edit, jump to it, otherwise apply it if any
      if not require("sidekick").nes_jump_or_apply() then
        return "<Tab>" -- fallback to normal tab
      end
    end,
    expr = true,
    desc = "Goto/Apply Next Edit Suggestion",
  },
  {
    "<c-.>",
    function()
      require("sidekick.cli").toggle()
    end,
    desc = "Sidekick Toggle",
    mode = { "n", "t", "i", "x" },
  },
  {
    "<leader>aa",
    function()
      require("sidekick.cli").toggle()
    end,
    desc = "Sidekick Toggle CLI",
  },
  {
    "<leader>as",
    function()
      require("sidekick.cli").select()
    end,
    -- Or to select only installed tools:
    -- require("sidekick.cli").select({ filter = { installed = true } })
    desc = "Select CLI",
  },
  {
    "<leader>ad",
    function()
      require("sidekick.cli").close()
    end,
    desc = "Detach a CLI Session",
  },
  {
    "<leader>at",
    function()
      require("sidekick.cli").send({ msg = "{this}" })
    end,
    mode = { "x", "n" },
    desc = "Send This",
  },
  {
    "<leader>af",
    function()
      require("sidekick.cli").send({ msg = "{file}" })
    end,
    desc = "Send File",
  },
  {
    "<leader>av",
    function()
      require("sidekick.cli").send({ msg = "{selection}" })
    end,
    mode = { "x" },
    desc = "Send Visual Selection",
  },
  {
    "<leader>ap",
    function()
      require("sidekick.cli").prompt()
    end,
    mode = { "n", "x" },
    desc = "Sidekick Select Prompt",
  },
  -- Example of a keybinding to open Claude directly
  -- {
  --   "<leader>ac",
  --   function()
  --     require("sidekick.cli").toggle({ name = "claude", focus = true })
  --   end,
  --   desc = "Sidekick Toggle Claude",
  -- },
}

return M
