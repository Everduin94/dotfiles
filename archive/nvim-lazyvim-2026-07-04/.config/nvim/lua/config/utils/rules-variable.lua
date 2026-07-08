local config = require("codecompanion.config")

---@class CodeCompanion.Variable.ViewPort: CodeCompanion.Variable
local Variable = {}

---@param args CodeCompanion.VariableArgs
function Variable.new(args)
  local self = setmetatable({
    Chat = args.Chat,
    config = args.config,
    params = args.params,
  }, { __index = Variable })

  return self
end

---Return the contents of the general rules file as a chat message
---@return nil
function Variable:output()
  local filepath = "/Users/erik/dotfiles/all/rules/general.md"

  -- Read all lines from the file
  local lines = vim.fn.readfile(filepath)
  local content = table.concat(lines, "\n")

  self.Chat:add_message({
    role = config.constants.USER_ROLE,
    content = content,
  }, { tag = "variable", visible = false })
end

return Variable
