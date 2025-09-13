local M = {}
local util = require("modules.ai.ai-util")

vim.api.nvim_create_user_command("RunPythonTask", util.run_python_task, {})
vim.api.nvim_create_user_command("StopPythonTask", util.stop_python_task, {})

vim.keymap.set("n", "<leader>rp", "<cmd>RunPythonTask<cr>", { desc = "Run Python Task" })
vim.keymap.set("n", "<leader>ro", "<cmd>CodeCompanionChat<cr>", { desc = "Start new AI Chat" })
vim.keymap.set("v", "<leader>ro", ":CodeCompanion ", { desc = "Start new AI assistant" })
vim.keymap.set("n", "<leader>re", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle existing AI Chat" })
return M
