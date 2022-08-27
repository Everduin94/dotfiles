
-- TODO: Using a variable feels bad, but running hello twice also feels bad :/
-- Is there a way to maintain state, say inside quick switcher, and handle this performantly?
-- Regardless, the idea works :)

-- lualine_x = {{ hello, color = randomColor }, 'filetype'},
local tempState = ''

local function hello()
  local file_name = vim.fn.expand('%:t')
  local temp = file_name:match('%.([%-%w_]+)%.%w+$')
  if temp == nil then
    tempState = ''
    return ''
  end
  tempState = string.upper(temp)
  return tempState
end

-- Should be highlights for consistency or is there a way to pull from theme?
local componentColors = {
  STORE = '#73daca',
  REPOSITORY = '#73daca',
  QUERY = '#9ece6a',
  SELECTORS = '#9ece6a',
  EFFECTS = '#bb9af7',
  ACTIONS = '#f7768e',
  MODULE = '#f7768e',
  REDUCER = '#7aa2f7',
  COMPONENT = '#7dcfff',
  SERVICE = '#e0af68',
  SPEC = '#c0caf5',
}

local function randomColor()
  return { fg = '#111111', bg = tempState and componentColors[tempState] or '' }
end

require'lualine'.setup {
  options = {
    icons_enabled = true,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {{'branch', fmt = function(str) local parts = vim.fn.split(str, '/', true); return parts[#parts] end }, 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    -- lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_x = {'filetype'},
    -- lualine_x = {{ hello, color = {fg = '#111111', bg = randomColor() }}},
    -- lualine_x = {  {hello(tempState), color = randomColor } },
    -- lualine_y = {'progress'},
    lualine_y = {},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}
