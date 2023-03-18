
local M = {}

-- Learning
  -- It seems like all OS.Execute will fire, then, once all are complete: tmux sends all the commands
  -- ex: if you write 4 tmux.send, it will print result of each one. Then run each one.
function M.send(cmd, session, window)
  local loc = '"=' .. session .. ':=' .. window .. '"'
  os.execute('tmux send-keys -t ' .. loc .. ' Escape ' .. ' "' .. cmd .. '" Enter')
end

function M.new_session(name, window_name)
  os.execute('tmux new-session -d -s ' .. name)
  if window_name then
    os.execute('tmux rename-window ' .. window_name)
  end
end

function M.new_window(session, name, dir)
  os.execute('tmux new-window -d -t "=' .. session .. '" -n ' .. name .. ' -c ' .. dir)
end

function M.attach(session)
  os.execute('TERM=xterm-256color tmux -2 attach -t "=' .. session .. '"')
end

function M.refresh(env)  
  local sesh = env
  local noteWindow = 'Notes'
  M.send(':qa', sesh, noteWindow)
  M.send('n', sesh, noteWindow)
end

function M.init(env)
  local sesh = env
  local noteWindow = 'Notes'
  local projectWindow = 'Project'
  local serverWindow = 'Servers'
  M.new_session(sesh, 'Config')
  M.new_window(sesh, noteWindow, os.getenv('WS_NOTES'))
  M.send('n', sesh, noteWindow)
  M.new_window(sesh, projectWindow, os.getenv('WS_CX_CLOUD'))
  M.send('n', sesh, projectWindow)
  M.new_window(sesh, serverWindow, os.getenv('WS_CX_CLOUD'))
end

return M
