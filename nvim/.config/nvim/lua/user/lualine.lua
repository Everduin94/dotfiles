
-- TODO: Using a variable feels bad, but running hello twice also feels bad :/
-- Is there a way to maintain state, say inside quick switcher, and handle this performantly?
-- Regardless, the idea works :)

local tempState = 'None'

local function hello() 
  local file_name = vim.fn.expand('%:t')
  local temp = file_name:match('%.([%-%w_]+)%.%w+$')

  if temp == nil then
    tempState = 'None'
    return 'None'
  end
  tempState = temp
  
  return temp
end


local function randomColor()
  
  local color = '#123456'
  if tempState == 'store' then
    color = '#BADA55'
  end

  return { fg = '#111111', bg = color }
end

local function test_mode() 
  return { hello, color = randomColor }
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
