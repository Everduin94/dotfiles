local home = os.getenv("HOME")
package.path = package.path .. ';' .. home .. '/.config/lua-scripts/?.lua'

local git = require("git-util")
local fu = require("file-util")
local tu = require("tmux-util")
local fGenerator = require("file-generator")

local function run(...)
  local args = {...}
  local program = args[1]
  if program == 'push' then
    return git.push(args[2])
  elseif program == 'commit' then
    return git.commit(git.buildCommitMessage(args[2], args[3], args[4], args[5], args[6]))
  elseif program == 'committemp' then
    return git.commitTemp(args[2])
  elseif program == 'ticket' then
    return git.getTicketTag()
  elseif program == 'checkout' then
    return git.checkout(args[2], args[3])
  elseif program == 'sync' then
    return git.sync()
  elseif program == 'init' then
    return git.init(args[2])
  elseif program == 'fb-kill' then
    return fu.firebase_kill()
  elseif program == 'folder-name' then
    return fu.getFolderName(args[2])
  elseif program == 'work' then
    return tu.init('DEV')
  elseif program == 'home' then
    return tu.init('DEV')
  elseif program == 'attach' then
    if args[2] == 'work'  then
      tu.attach('DEV')
    elseif args[2] == 'home' then
      tu.attach('DEV')
    end
  elseif program == 'od' then
    return fu.open_dir(args[2])
  elseif program == 'n-major' then
    return fGenerator.major_node(arg[2])
  elseif program == 'n-minor' then
    return fGenerator.minor_node(arg[2])
  elseif program == 'n-module' then
    return fGenerator.notes_module(args[2], args[3])
  elseif program == 'n-sprint' then
    return fGenerator.sprint_module(args[2])
  elseif program == 'n-day' then
    return fGenerator.sprint_day()
  elseif program == 'n-tmrw' then
    return fGenerator.sprint_tmrw()
  elseif program == 'css-props' then
    return fGenerator.cssPropsToCustom(args[2])
  end
end


print(run(...))
