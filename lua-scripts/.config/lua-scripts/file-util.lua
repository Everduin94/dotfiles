
local M = {}

-- Learning
  -- Lua is single threaded blocking. You can only read or write at a time
function M.updateFile(fileName, fn, mode, copyFileName)
  -- Default mode "w"
  mode = mode or "w"

  -- Read
  local f = assert(io.open(fileName, "r"))
  local t = f:read("*all")
  f:close()

  -- Mutate
  if fn then
    t = fn(t)
  end

  -- Write or Copy
  local updatedFileName = fileName
  if copyFileName then
    updatedFileName = copyFileName
  end

  -- Write
  f = assert(io.open(updatedFileName, mode))
  f:write(t)
  f:close()
end

function M.readAll(command)
  local handle = io.popen(command);
  local result = handle:read("*a"); -- *a reads whole file
  handle:close();
  return result;
end

function M.readLines(command)
  local handle = io.popen(command);
  local result = handle:read("*l");
  handle:close();
  return result;
end

function M.getcwd()
 local pipe = assert(io.popen('pwd'))
 local path = assert(pipe:read('*l'))
 pipe:close()
 return path
end

function M.isCxCloud()
  local pwd = M.getcwd()
  return string.find(pwd, 'cx%-cloud%-ui')
end

function M.escape(...)
 local command = type(...) == 'table' and ... or { ... }
 for i, s in ipairs(command) do
  s = (tostring(s) or ''):gsub('"', '\\"')
  if s:find '[^A-Za-z0-9_."/-]' then
   s = '"' .. s .. '"'
  elseif s == '' then
   s = '""'
  end
  command[i] = s
 end
 return table.concat(command, ' ')
end

-- Relies on lua_cd
function M.open_dir(option)
  -- Learning
    -- Had to escape t, otherwise strings/n doesn't work
    -- Had to echo, otherwise fzf is empty
    -- Had to use readAll, otherwise os.execute returns true
    -- FZF 'filter' option is what allowed me to auto select
    -- Biggest hurdle: execute cd only works in child process.
      -- Thus: things like `cd dir` `touch file` work.
      -- But you can't actually change the shell's pwd
      -- How we get around this:
        -- Created a function in aliases
        -- cd $(l $1 $2) where 1 is lua name and 2 is input
        -- return string in function
  local home = os.getenv('HOME')
  local f = assert(io.open(home .. '/projects', "r"))
  local t = f:read("*all")
  f:close()

  local noArgs = option == nil or option:match("^%s*(.-)%s*$") == ''
  local query = noArgs and '' or ' --filter=' .. option:match("^%s*(.-)%s*$")
  local result = M.readAll('echo ' .. M.escape(t) .. ' | fzf' .. query)
  return result
end

-- Learning
  -- sub is inclusive. (1, -2), means grab from first character, to the second to last character.
  -- i.e. include the second to last character, i.e. remove **only** the last character
  -- sub(1, #pathName - 1) is the name thing
function M.getFolderName(pathName)
  local endsWithSlash = pathName:sub(-1) == '/'
  pathName = endsWithSlash and pathName:sub(1, -2) or pathName
  return string.match(M.escape(pathName), '.*/(.*)$')
end


function M.firebase_kill()
  local getUser = "id -un"
  local user = M.readAll(getUser);

  local ports = {
    "8080",
    "4202",
    "9099",
    "5000",
  }

  local sudo = user == 'erik' and 'sudo' or ''
  for k, port in pairs(ports) do
    local command = "lsof -ti :" .. port
    local result = M.readAll(command);
    if result then
      os.execute(sudo .. ' kill -9 ' .. result)
    end
  end
end



return M

