local git = require("git-util")
local fu = require("file-util")
local tu = require("tmux-util")
local term   = require 'term'
local posix = require 'posix.stdlib'
local colors = term.colors -- or require 'term.colors'

-- find . -name '*.lua' | entr lua 



local sesh = 'wow'
local window = 'one'
tu.new_session(sesh)
tu.new_window(sesh, window, '~/dotfiles')
tu.send('pwd', sesh, window)
