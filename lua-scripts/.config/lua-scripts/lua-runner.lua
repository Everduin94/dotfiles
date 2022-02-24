local home = os.getenv("HOME")
package.path = package.path .. ';' .. home .. '/.config/lua-scripts/?.lua'

local git = require("git-util")

local function run(...)
  local args = {...}
  local program = args[1]
  if program == 'push' then
    return git.push(args[2])
  elseif program == 'commit' then
    return git.commit(git.buildCommitMessage(args[2], args[3], args[4], args[5], args[6]))
  elseif program == 'committemp' then
    return git.commitTemp(args[2])
  elseif program == 'cxcheckout' then
    return git.cxCheckout(args[2], args[3])
  elseif program == 'init' then
    return git.init()
  end
end


print(run(...))
