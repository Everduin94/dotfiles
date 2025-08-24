local M = {}
local job_id = nil
local python_file = vim.fn.stdpath("config") .. "/lua/scripts/faster-whisper.py"
local noice = require("noice")

function M.run_python_task()
  noice.notify("Start recording...", "info")
  job_id = vim.fn.jobstart({ "python3", python_file }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(_, exit_code)
      if exit_code == 0 or exit_code == 137 then
        noice.notify("Fast Whisper Complete.", "info")
      else
        print(exit_code)
        noice.notify("Error: Faster Whisper Failed.", "error")
      end
      job_id = nil
    end,
  })

  if job_id <= 0 then
    noice.notify("Error: Failed to start Faster Whisper.", "error")
  end
end

function M.stop_python_task()
  if job_id and job_id > 0 then
    vim.fn.jobstop(job_id)
    noice.notify("Stopped Faster Whisper.", "info")
    job_id = nil
  else
    noice.notify("Faster Whisper is not running.", "warn")
  end
end

return M
