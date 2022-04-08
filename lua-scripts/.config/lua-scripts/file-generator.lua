local fu = require("file-util")
local su = require("string-util")
local M = {}

local NOTES_MODULE_FILES = {
  '.index.md',
  '.maps.md',
  '.todo.md',
  '.references.md',
  '.notes.md',
}

function M.notes_module(name, options)
  local cwd = fu.getcwd();
  local path = cwd .. '/';
  -- TODO: Need to introduce lib to handle flags?
  if options == nil or options.flat ~= true then
    path = cwd .. '/' .. name .. '/'
    os.execute('mkdir ' .. path);
  end
  for k, v in pairs(NOTES_MODULE_FILES) do
    os.execute('touch ' .. path .. name .. v);
  end
end


local SPRINT_MODULE_FILES = {
  '.month.md',
  '.week-1.md',
  '.week-2.md',
  '.week-3.md',
  '.week-4.md',
}

function M.sprint_module(name)
  local cwd = fu.getcwd();
  local year = os.date("%Y");
  name = year .. '-' .. name
  local path = cwd .. '/' .. name .. '/'
  os.execute('mkdir ' .. path);
  for k, v in pairs(SPRINT_MODULE_FILES) do
    os.execute('touch ' .. path .. name .. v);
  end
end

function M.sprint_day()
  local cwd = fu.getcwd();
  local path = cwd .. '/'
  local todaysDate = string.gsub(os.date("%x"), "/", "-")
  os.execute('touch ' .. path .. todaysDate .. '.sprint.md');
end

function M.sprint_tmrw()
  local cwd = fu.getcwd();
  local path = cwd .. '/'
  local todaysDate = string.gsub(os.date("%x", os.time()+(24*60*60)), "/", "-")
  os.execute('touch ' .. path .. todaysDate .. '.sprint.md');
end

function M.major_node(name)
  local cwd = fu.getcwd();
  local path = cwd .. '/' .. name .. '/'
  os.execute('mkdir ' .. path);
  os.execute('cd ' .. name)
  os.execute('touch ' .. path .. name .. '.md');
end

-- something-what-okay --> # Something What Okay
function splitFileName(fileName)
        local result = ""
        local separator = "# ";
        for word in fileName:gmatch("%w+") do
          result = result .. separator .. word:gsub("^%l", string.upper)
          separator = " "
        end
        return result
end

-- 03/21/2022 (%x is 03/21/22)
function getFullDate()
  return os.date("%m") .. '/' .. os.date("%d") .. '/' .. os.date('%Y')
end

function M.minor_node(name)
  local cwd = fu.getcwd();
  local path = cwd .. '/'
  local fileName = path .. name .. '.md'
  local scripts_path = os.getenv('WS_SCRIPTS')
  local template = scripts_path .. '/templates/minor-node.md'
  local parentFile = fu.getFolderName(cwd) .. '.md'
  local updateFn = function (input)
    local updates = input
    updates = string.gsub(updates, 'FILE', splitFileName(name))
    -- updates = string.gsub(updates, 'TAG', '#' .. nil)
    updates = string.gsub(updates, 'DATE', 'Created: ' .. getFullDate())

    -- Major node is always foldername + .md
    updates = string.gsub(updates, 'BACK', 'Back: [[' .. parentFile .. ']]')
    return updates
  end

  fu.updateFile(template, updateFn, 'w', fileName)

  local appendFn = function(input)
    return '- [[' .. name .. '.md' .. ']]\n'
  end
  fu.updateFile(parentFile, appendFn, 'a')
end


return M
