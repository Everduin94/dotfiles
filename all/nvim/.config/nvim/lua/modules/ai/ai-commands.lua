local M = {}
local util = require("modules.ai.ai-util")

vim.api.nvim_create_user_command("RunPythonTask", util.run_python_task, {})
vim.api.nvim_create_user_command("StopPythonTask", util.stop_python_task, {})

vim.keymap.set("n", "<leader>rp", "<cmd>RunPythonTask<cr>", { desc = "Run Python Task" })
vim.keymap.set("n", "<leader>rs", "<cmd>StopPythonTask<cr>", { desc = "Stop Python Task" })

return M
