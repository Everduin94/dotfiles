local fu = require("file-util")
local su = require("string-util")
M = {}

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
  relation = relation or "Closes"
  local ticket = M:getTicketTag()
  local fMessage = ctype .. "(" .. scope .. "): " .. title .. "\n\n" .. description .. "\n\n" .. relation .. ": " .. ticket
  return su.trim(fMessage);
end

function M.commit(msg)
  return os.execute('git commit -m "' .. msg .. '"')
end

function M.commitTemp(msg)
  msg = msg or "Saving work"
  local ticket = M:getTicketTag()
  local tempMsg = ticket .. " Temp Commit (Rebase): "
  return os.execute('git commit -m "' .. tempMsg .. msg .. '" --no-verify')
end

function M.push(flags)
  flags = fu.escape(flags) or ''
  local branchName = M:getBranchName();
  return os.execute('git push origin ' .. branchName .. ' ' .. flags)
end

function M.cxCheckout(numberAndName, ctype)
  ctype = ctype or "feat"
  return os.execute('git checkout -b everduin94/' .. ctype .. '/CCFC-' .. numberAndName)
end

return M
