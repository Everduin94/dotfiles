local mocha = require("catppuccin.palettes").get_palette "mocha"

local cat = require'lualine.themes.catppuccin'
cat.normal.c = { bg = '#181825', fg = mocha.text}
cat.inactive.a = { bg = '#181825', fg = mocha.blue}
cat.inactive.b = { bg = '#181825', fg = mocha.surface, gui ="bold" }
cat.inactive.c = { bg = '#181825', fg = mocha.overlay0 }


local file_to_color = {
  lualine = mocha.mauve,
  cmp = mocha.teal,
  harpoon = mocha.red
}

-- if file extension is .svelte
  -- and path includes 'routes'
    -- then get the first viable path name

-- Use this or index the table by key
function includes(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

local function is_svelte_kit_route(path) 
   return includes(path, 'routes')
end


local function is_types(path, file) 
   return includes(path, 'types') or includes(file, 'type') or includes(file, 'model')  or includes(file, 'models')
end

local function reverse_find_svelte_page_title(path) 
  local result = '';
  local value = '';
  for i = #path - 1, 1, -1 do
    value = path[i]
    local isParam = value:match('%[([%-%w_]+)%]')
    if not isParam then
      if value == 'routes' then
        return 'Root' .. result
      end
      return value .. result
    else 
      result = '-' .. isParam
    end
  end
end


-- Angular checks
local function is_component(file) return includes(file, 'component') end
local function is_module(file) return includes(file, 'module') end
local function is_styles(file) return includes(file, 'scss') or includes(file, 'css') or includes(file,'postcss') end
local function is_html(file) return includes(file, 'html') end
local function is_service(file) return includes(file, 'service') end
local function is_test(file) return includes(file, 'test') or includes(file, 'spec') end
local function is_effect(file) return includes(file, 'effects') end
local function is_selector(file) return includes(file, 'selectors') or includes(file, 'selector')  end
local function is_action(file) return includes(file, 'actions') end
local function is_reducer(file) return includes(file, 'reducer') end
local function is_facade(file) return includes(file, 'facade') end
local function is_repository(file) return includes(file, 'repository') end
local function is_store(file) return includes(file, 'store') end


local sub_mode = 'Buffer'

-- Sub mode

-- Git
vim.keymap.set('n', '<leader>gk', 
    function()
      require('gitsigns').next_hunk()
      vim.keymap.set('n', '<TAB>', '<cmd>lua require([[gitsigns]]).next_hunk() <CR>')
      vim.keymap.set('n', '<S-TAB>', '<cmd>lua require([[gitsigns]]).prev_hunk() <CR>')
      sub_mode = 'Git'
    end,
opts)

-- Diagnostic
vim.keymap.set('n', '<leader>gn', 
    function()
      vim.diagnostic.goto_next()
      vim.keymap.set('n', "<TAB>", "<cmd>lua vim.diagnostic.goto_next() <CR>")
      vim.keymap.set('n', "<S-TAB>", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
      sub_mode = 'Diagnostic'
    end,
opts)

-- Quick Fix
vim.keymap.set('n', '<leader>gx', 
    function()
      vim.api.nvim_command('copen')
      vim.keymap.set('n', '<TAB>', '<cmd>cn<CR>zz')
      vim.keymap.set('n', '<S-TAB>', '<cmd>cp<CR>zz')
      sub_mode = 'Quick Fix'
    end,
opts)

-- Clear
vim.keymap.set('n', '<leader>g/', 
    function()
      vim.keymap.set('n', '<TAB>', '<cmd>bnext<CR>')
      vim.keymap.set('n', '<S-TAB>', '<cmd>bprevious<CR>')
      sub_mode = 'Buffer'
    end,
opts)

-- Spellcheck
vim.keymap.set('n', '<leader>gs', 
    function()
      vim.api.nvim_feedkeys(']s', 'n', false)
      vim.keymap.set('n', '<TAB>', ']s')
      vim.keymap.set('n', '<S-TAB>', '[s')
      sub_mode = 'Spellcheck'
    end,
opts)

-- vim.keymap.set('n', '<leader>gk', 
--     function()
--       require('gitsigns').next_hunk()
--       vim.keymap.set('n', '<TAB>', '<cmd>lua require([[gitsigns]]).next_hunk() <CR>')
--       vim.keymap.set('n', '<S-TAB>', '<cmd>lua require([[gitsigns]]).prev_hunk() <CR>')
--       sub_mode = 'Git'
--     end,
-- opts)


-- Autocmd Test
local SWITCHER_TAGS = {
  titl = '',
  color = mocha.red,
  has_entry = nil,
}

local function write_file_name()

   local full_path = vim.fn.expand('%:~:.')
   if full_path == nil then return end
   local all_file_parts = vim.split(full_path, '/')

   local file_name = vim.fn.expand('%:t')
   if file_name == nil then return false end
   local file_parts = vim.split(file_name, '%.')

   if is_svelte_kit_route(all_file_parts) then
     SWITCHER_TAGS.title = reverse_find_svelte_page_title(all_file_parts)
     SWITCHER_TAGS.color = mocha.teal
  elseif is_styles(file_parts) then
     SWITCHER_TAGS.title = 'Styles'
     SWITCHER_TAGS.color = mocha.sky
  elseif is_html(file_parts) then
     SWITCHER_TAGS.title = 'Template'
     SWITCHER_TAGS.color = mocha.teal
  elseif is_test(file_parts) then
     SWITCHER_TAGS.title = 'Test'
     SWITCHER_TAGS.color = mocha.green
   elseif is_component(file_parts) then
     SWITCHER_TAGS.title = 'Component'
     SWITCHER_TAGS.color = mocha.blue
  elseif is_module(file_parts) then
     SWITCHER_TAGS.title = 'Module'
     SWITCHER_TAGS.color = mocha.red
  elseif is_service(file_parts) then
     SWITCHER_TAGS.title = 'Service'
     SWITCHER_TAGS.color = mocha.yellow
  elseif is_effect(file_parts) then
     SWITCHER_TAGS.title = 'Effect'
     SWITCHER_TAGS.color = mocha.mauve
  elseif is_action(file_parts) then
     SWITCHER_TAGS.title = 'Action'
     SWITCHER_TAGS.color = mocha.red
  elseif is_reducer(file_parts) then
     SWITCHER_TAGS.title = 'Reducer'
     SWITCHER_TAGS.color = mocha.blue
  elseif is_facade(file_parts) then
     SWITCHER_TAGS.title = 'Facade'
     SWITCHER_TAGS.color = mocha.flamingo
  elseif is_selector(file_parts) then
     SWITCHER_TAGS.title = 'Selector'
     SWITCHER_TAGS.color = mocha.sky
  elseif is_types(all_file_parts, file_parts) then
     SWITCHER_TAGS.title = 'Types'
     SWITCHER_TAGS.color = mocha.lavender
   else 
     SWITCHER_TAGS.title = ''
   end

   SWITCHER_TAGS.has_entry = SWITCHER_TAGS.title ~= nil and SWITCHER_TAGS.title ~= ''
end

vim.api.nvim_create_autocmd({ "BufEnter" }, { callback = write_file_name })
-- End

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

local function getFileName()
  local full_file = vim.fn.expand('%:t')
  local file_parts = vim.split(full_file, '%.')
  local file_name = file_parts[1]
  
 -- , color = { fg = componentColors[file_name] }
  return {file_name,  color = { fg = file_to_color[file_name] }}
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

local function getFileColor()
  local fg_color = mocha.overlay1
  if is_focus == 'Focus' then
    fg_color = mocha.teal
  end
  return { fg = fg_color, bg = '#181825' }
end


local colors = {
  bg       = '#202328',
  fg       = '#bbc2cf',
  yellow   =  mocha.yellow,
  cyan     =  mocha.sky,
  darkblue = '#081633',
  green    =  mocha.green,
  orange   =  mocha.peach,
  violet   =  mocha.lavender,
  magenta  =  mocha.mauve,
  blue     =  mocha.blue,
  red      =  mocha.red,
}

local function getModeColor(fg)
    -- auto change color according to neovims mode
    local mode_color = {
      n = colors.blue,
      i = colors.green,
      v = colors.magenta,
      [''] = colors.magenta,
      V = colors.magenta,
      c = colors.yellow,
      no = colors.red,
      s = colors.orange,
      S = colors.orange,
      [''] = colors.orange,
      ic = colors.yellow,
      R = colors.violet,
      Rv = colors.violet,
      cv = colors.red,
      ce = colors.red,
      r = colors.cyan,
      rm = colors.cyan,
      ['r?'] = colors.cyan,
      ['!'] = colors.red,
      t = colors.orange,
    }
    if fg then
      return { bg = mode_color[vim.fn.mode()], fg='#11111b', gui='bold' }
    end

    return { fg = mode_color[vim.fn.mode()], bg=mocha.surface0, gui='bold' }
  end

local function get_sub_mode_color() 
    local sub_mode_color = {
      Git = colors.green,
      Buffer = colors.blue
    }
    return { fg = sub_mode_color[sub_mode], bg='#11111b', gui='italic,bold' }
end

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}


local function get_file_name()
  return SWITCHER_TAGS.title
end

local function get_color_name()
  return  { fg = SWITCHER_TAGS.color, bg='#181825' }
end

-- # Good example of an integration, but we decided to just color file name
-- {hello, color={ bg='#181825', fg=mocha.teal, gui='bold'}, cond = function() if is_focus == 'Focus' then return true end end }


local function get_mode_icon()
  if sub_mode == 'Buffer' then
    return '󰀘'
  end
  if sub_mode == 'Quick Fix' then
    return ''
  end
  if sub_mode == 'Git' then
    return ''
  end
  if sub_mode == 'Diagnostic' then
    return '󱩔'
  end
  if sub_mode == 'Spellcheck' then
    return '󰓆'
  end
end

sections = { lualine_a = { hello } }
require'lualine'.setup {
  options = {
    theme = cat,
    icons_enabled = true,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = '' },
    disabled_filetypes = {},
    always_divide_middle = false,
  },
  sections = {
    -- padding = { left = 2, right = 2} 󰝴
    lualine_a = {{'mode', fmt = function(str) return get_mode_icon() end,  color = function() return getModeColor('fg') end, padding = { right = 2, left = 1}  }, {'branch', fmt = function(str) local parts = vim.fn.split(str, '/', true); return parts[#parts] end, color = function() return getModeColor() end, padding = {left = 1, right = 1} }},
    -- lualine_b =  {} ,
    lualine_b = {{'filetype', icon_only = true, padding = {right = 0, left = 1}, cond = conditions.buffer_not_empty, color = {bg = '#181825'}}, {'filename', color = function() return getFileColor() end, cond = conditions.buffer_not_empty, symbols = {modified = '●'}}, {get_file_name, color= function() return get_color_name() end, cond = function() if SWITCHER_TAGS.has_entry == true then return true end end } },
    lualine_c = {'%='},
    -- lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_x = {},
    -- lualine_x = {{ hello, color = {fg = '#111111', bg = randomColor() }}},
    -- lualine_x = {  {hello(tempState), color = randomColor } },
    -- lualine_y = {'progress'},
    lualine_y = {},
    lualine_z = {  }
-- {'custom', fmt = function(str) return sub_mode end, color = function() return get_sub_mode_color() end}
    -- lualine_b = {{'branch', fmt = function(str) local parts = vim.fn.split(str, '/', true); return parts[#parts] end, color = function() return getModeColor() end, padding = {left = 1, right = 2} }},
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
