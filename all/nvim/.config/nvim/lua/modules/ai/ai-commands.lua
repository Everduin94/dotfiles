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

return M
