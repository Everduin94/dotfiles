local git = require("git-util")
local fu = require("file-util")
local su = require("string-util")
local cu = require("css-util")
local tu = require("tmux-util")
local term   = require 'term'
local posix = require 'posix.stdlib'
local colors = term.colors -- or require 'term.colors'

-- find . -name '*.lua' | entr lua 

  local getUser = "id -un"
  local user = fu.readAll(getUser);

  local ports = {
    "8080",
    "4202",
    "9099",
  }

  local sudo = user == 'erik' and 'sudo' or ''
  for k, port in pairs(ports) do
    local command = "lsof -ti :" .. port
    local result = fu.readAll(command);
    if result then
      os.execute(sudo .. ' kill -9 ' .. result)
    end
  end


-- print(pid)


-- local sesh = 'wow'
-- local window = 'one'
-- tu.new_session(sesh)
-- tu.new_window(sesh, window, '~/dotfiles')
-- tu.send('pwd', sesh, window)
