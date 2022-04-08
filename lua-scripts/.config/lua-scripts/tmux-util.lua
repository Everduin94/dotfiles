
local M = {}

-- Learning
  -- It seems like all OS.Execute will fire, then, once all are complete: tmux sends all the commands
  -- ex: if you write 4 tmux.send, it will print result of each one. Then run each one.
function M.send(cmd)
  os.execute('tmux send "' .. cmd .. '" Enter')
end

return M
