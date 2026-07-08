-- TODO: Move me to modules
local function read_rules()
  local path = "/Users/erik/dotfiles/all/rules/general.md"
  local file, err = io.open(path, "r")
  if not file then
    return nil, err
  end
  local content = file:read("*a")
  file:close()
  return content
end

return read_rules
