local fu = require("file-util")
local su = require("string-util")
local tu = require("tmux-util")
local posix = require("posix.stdlib")
local M = {}

function M.getBranchName()
  local command = "git rev-parse --abbrev-ref HEAD"
  local result = fu.readAll(command);
  return su.trim(result);
end

function M.getTicketTag()
  local branchName = M:getBranchName()
  local name = string.match(branchName, "/(%a*-%d*)-")
  return su.trim(name);
end

function M.buildCommitMessage(ctype, scope, title, description, relation)
  relation = relation or ""
  local isCx = fu.isCxCloud();
  local ticket = isCx and M:getTicketTag() or ''
  local fMessage = ctype .. "(" .. scope .. "): " .. title .. "\n\n" .. description .. "\n\n" .. relation .. ": " .. ticket
  return su.trim(fMessage);
end

function M.sync()
  local user = os.execute('id -un')
  local machine = 'HOME'
  if user == 'everduin' then
    machine = 'WORK'
  end

   os.execute('git add .')
   os.execute('git commit -m "' .. "Syncing from ".. machine .. ": " .. os.date("%x") .. '"')
   M.push()
end

function M.commit(msg)
  return os.execute('git commit -m "' .. msg .. '"')
end

function M.commitTemp(msg)
  msg = msg or "Saving work"
  local isCx = fu.isCxCloud();
  local ticket = isCx and M:getTicketTag() or ''
  local tempMsg = ticket .. " Temp Commit (Rebase): "
  return os.execute('git commit -m "' .. tempMsg .. msg .. '" --no-verify')
end

function M.push(flags)
  flags = fu.escape(flags) or ''
  local branchName = M:getBranchName();
  return os.execute('git push origin ' .. branchName .. ' ' .. flags)
end

function M.checkout(numberAndName, ctype)
  ctype = ctype or "feat"
  return os.execute('git checkout -b everduin94/' .. ctype .. '/CCFC-' .. numberAndName)
end

function M.init(update_in_place)
  local auth = os.getenv("WS_CX_CLOUD") .. '/utils/scripts/auth.sh'
  local env = os.getenv('WS_SCRIPTS')
  local awsAuthCmd = 'source ' .. env .. '/aws-auth.sh'
  io.write('🕵  Authenticating (Duo)... \n')
  os.execute('source ' .. auth)
  io.write('🎭 Updating AWS Auth Token \n')
  local result = fu.readAll(awsAuthCmd)
  posix.setenv('CODEARTIFACT_AUTH_TOKEN', result)
  io.write(posix.getenv('CODEARTIFACT_AUTH_TOKEN'))
  if not update_in_place then
    io.write('📦 Changes will be stashed... \n')
    os.execute('git stash')
    io.write('🌱 Checking out main... \n')
    os.execute('git checkout main')
  end
  io.write('📩 Pulling latest changes... \n')
  os.execute('git pull -r origin main')
  io.write('🧪 Installing dependencies... \n')
  os.execute('npm ci')
  io.write('✅ Complete! \n')
end

return M
