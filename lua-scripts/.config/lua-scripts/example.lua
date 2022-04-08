local git = require("git-util")
local fu = require("file-util")
local tu = require("tmux-util")
local term   = require 'term'
local posix = require 'posix.stdlib'
local colors = term.colors -- or require 'term.colors'

-- find . -name '*.lua' | entr lua 

-- POC Switcher find
local result = fu.readAll('find . -maxdepth 2 -name "*.md"')

local tableResults = {}
for s in result:gmatch("[^\r\n]+") do
    table.insert(tableResults, s)
end

-- POC Tmux Exports
local env = os.getenv('WS_SCRIPTS')
-- os.execute('tmux send "source ' .. env .. '/aws-auth.sh"')



-- local results = tu.send('source ' .. env .. '/aws-auth.sh')
print(posix.setenv('CODEARTIFACT_AUTH_TOKEN', fu.readAll('echo 123')))


print(posix.getenv('CODEARTIFACT_AUTH_TOKEN'))
