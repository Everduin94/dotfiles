-- Highlight for longer (for webex)
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  pattern = { "*" },
  command = "lua vim.highlight.on_yank({higroup='IncSearch', timeout = 2000}) ",
})

-- Reload svelte files
vim.api.nvim_create_autocmd({ "BufWrite" }, {
  pattern = { "+page.server.ts", "+page.ts", "+layout.server.ts", "+layout.ts" },
  command = "LspRestart svelte",
})

local map = LazyVim.safe_keymap_set
function set_term_keymaps()
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-[>", [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
  map("t", [[<C-\>]], [[<C-\><C-n>]], { desc = "Escape Terminal" })
end

vim.cmd("autocmd! TermOpen term://* lua set_term_keymaps()")

local function escapePattern(str)
  -- Escape all special pattern characters: ( ) . % + - * ? [ ^ $
  return str:gsub("([%.%+%-%*%?%[%]%(%)%^%$])", "%%%1")
end
-- local query = vim.treesitter.query.parse("html", [[
--     (element
--         (tag_name) @tagaaa
--         (#any-of? @tag "div" "span" "p")
--     ) @element
-- ]])

local ts_utils = require("nvim-treesitter.ts_utils")

local function debug_node(node, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Get the text content
  local text = vim.treesitter.get_node_text(node, bufnr)

  -- Get node type
  local type = node:type()

  -- Get node range
  local start_row, start_col, end_row, end_col = node:range()

  -- Get child nodes
  local children = {}
  for child in node:iter_children() do
    table.insert(children, {
      type = child:type(),
      text = vim.treesitter.get_node_text(child, bufnr),
    })
  end

  -- Print debug info
  print("Node Debug Info:")
  print("Type:", type)
  print("Text:", text)
  print(string.format("Range: [%d,%d] -> [%d,%d]", start_row, start_col, end_row, end_col))
  print("\nChildren:")
  for i, child in ipairs(children) do
    print(string.format("%d. %s: %s", i, child.type, child.text))
  end
end

local get_attributes = function(node, bufnr)
  local children = {}
  for child in node:iter_children() do
    local start_row, start_col, end_row, end_col = child:range()
    table.insert(children, {
      start_row = start_row,
      start_col = start_col,
      end_row = end_row,
      end_col = end_col,
      type = child:type(),
      text = vim.treesitter.get_node_text(child, bufnr),
    })
  end

  local filtered = {}

  for _, item in ipairs(children) do
    if item.type == "attribute" then
      table.insert(filtered, item)
    end
  end

  return filtered
end

local replacements = {
  ["cxui-button"] = "mag-button",
  ["variant="] = "kind=",
}

-- function vim.api.nvim_buf_set_lines(buffer, start, end_, strict_indexing, replacement) end
local replace_attribute_inline = function(attribute_node, bufnr)
  for key, value in pairs(replacements) do
    local safe_key = escapePattern(key)
    local found_key = attribute_node.text:find(safe_key)
    if found_key ~= nil then
      local updated_attribute = attribute_node.text:gsub(safe_key, value)
      vim.api.nvim_buf_set_text(
        bufnr,
        attribute_node.start_row,
        attribute_node.start_col,
        attribute_node.end_row,
        attribute_node.end_col,
        { updated_attribute }
      )
      return
    end
  end
end

local example = {
  end_col = 4,
  end_row = 508,
  start_col = 3,
  start_row = 502,
  text = 'variant="secondary"',
  type = "attribute",
}

-- Start Mag Migration Script
local get_root = function(bufnr, file_type)
  local parser = vim.treesitter.get_parser(bufnr, file_type, {})
  local tree = parser:parse()[1]
  return tree:root()
end

local icon_query = [[
(element
  (self_closing_tag
    (tag_name) @tag_name
    (#any-of? @tag_name "cxui-icon")
    (attribute
      (attribute_name) @attribute_name
      (quoted_attribute_value
        (attribute_value) @attribute_value
      ) @quoted_attribute_value
      (#any-of? @attribute_name "iconName" "[iconName]")
    ) @attribute
  ) @self_closing_tag
) @element
]]

local icon_map = {
  menuVertical = "dots-three-vertical",
}

local log_node = function(file_type, query_string)
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= file_type then
    return
  end

  local root = get_root(bufnr, file_type)

  local query = vim.treesitter.query.parse(file_type, query_string)
  local child_query = vim.treesitter.query.parse(file_type, icon_query)

  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    local attributes = get_attributes(node, bufnr)
    for _, attribute in ipairs(attributes) do
      replace_attribute_inline(attribute, bufnr)
    end

    local start_row, start_col, end_row, end_col = node:range()

    for _, match in child_query:iter_matches(node, bufnr) do
      for child_id, child_node in pairs(match) do
        if child_query.captures[child_id] == "element" then
          local icon_start_row, icon_start_col, icon_end_row, icon_end_col = child_node:range()
          vim.api.nvim_buf_set_lines(bufnr, icon_start_row + 1, icon_end_row + 2, false, {})
        end
        if child_query.captures[child_id] == "attribute_value" then
          local value = vim.treesitter.get_node_text(child_node, bufnr):gsub("^'(.+)'$", "%1")
          local safe_value = icon_map[value] and icon_map[value] or value
          vim.api.nvim_buf_set_lines(
            bufnr,
            start_row + 2,
            start_row + 2,
            false,
            { "iconName=" .. '"' .. safe_value .. '"' }
          )
        end
      end
    end

    -- ts_utils.goto_node(node, goto_end, avoid_set_jump)
  end
end

local TestMigrationScript = function()
  log_node(
    "html",
    [[
     (element
       (start_tag
         (attribute
          (attribute_name) @attribute_name
          (#any-of? @attribute_name "cxui-button")
         ) @attribute
       ) @start_tag
     ) @element
 ]]
  )
end

--    [[
--     (element
--       (start_tag
--         (tag_name) @tag
--         (#any-of? @tag "button")
--       ) @start_tag
--     ) @element
-- ]]

-- End Mag Migration Script

local function safeReplace(str, target, replacement)
  -- Escape the target string to avoid special character issues
  local escapedTarget = escapePattern(target)
  -- Replace the escaped target with the replacement string
  return str:gsub(escapedTarget, replacement)
end

local validProperties = {
  "padding",
  "margin",
  "border-radius",
  "border-width",
  "font-size",
  "line-height",
  "font-weight",
  "color",
  "background",
  "gap",
  "fill",
  "stroke",
}

-- Function to find CSS property from a string
local function findCssProperty(str)
  for _, property in ipairs(validProperties) do
    local escapedDash = property:gsub("-", "%%-")
    if str:match(escapedDash) then
      return property -- Return the first matched property
    end
  end
  return nil -- Return nil if no property matches
end

local function extractCssPropertyAndValue(cssString)
  local property, value = cssString:match("(%S+)%s*:%s*(.+)")
  return property, value
end

-- Commands
local function replace_values(lines, map)
  for i, line in ipairs(lines) do
    local cssProperty, cv = extractCssPropertyAndValue(line)
    if cssProperty and cv then
      local pureCssProperty = findCssProperty(cssProperty)
      if pureCssProperty then
        local cssPropertyTable = map[pureCssProperty]
        if cssPropertyTable then
          local cssValue = cv:gsub(";", "")
          for word in cssValue:gmatch("%S+") do
            local cssMagneticValue = cssPropertyTable[word]
            if cssMagneticValue then
              lines[i] = safeReplace(lines[i], word, cssMagneticValue)
            end
          end
        end
      end
    end
  end

  return lines
end

-- TODO: To get colors right you'd need to do like replace_value.
-- -- For now I'm just updating by hand (most names match)
-- -- e.g. info-bg-default and info-border-default
local function replace_magnetic_values(lines, map)
  for i, line in ipairs(lines) do
    local cssProperty, cv = extractCssPropertyAndValue(line)
    if cssProperty and cv then
      local cssValue = cv:gsub(";", "")
      for word in cssValue:gmatch("%S+") do
        local cssBaseValue = map[word]
        if cssBaseValue then
          lines[i] = safeReplace(lines[i], word, cssBaseValue)
        end
      end
    end
  end

  return lines
end

local mag_colors = {
  ["#005980"] = "var(--magnetic-color-sky-blue-35)",
  ["#006691"] = "var(--magnetic-color-sky-blue-40)",
  ["#0274a1"] = "var(--magnetic-color-sky-blue-45)",
  ["#027fb0"] = "var(--magnetic-color-sky-blue-50)",
  ["#028ec2"] = "var(--magnetic-color-sky-blue-55)",
  ["#049fd9"] = "var(--magnetic-color-sky-blue-60)",
  ["#09abe8"] = "var(--magnetic-color-sky-blue-65)",
  ["#14bdfa"] = "var(--magnetic-color-sky-blue-70)",
  ["#5ed4ff"] = "var(--magnetic-color-sky-blue-80)",
  ["#8ce0ff"] = "var(--magnetic-color-sky-blue-85)",
  ["#ade9ff"] = "var(--magnetic-color-sky-blue-90)",
  ["#d4f3ff"] = "var(--magnetic-color-sky-blue-95)",
  ["#1f5e06"] = "var(--magnetic-color-green-35)",
  ["#266b0b"] = "var(--magnetic-color-green-40)",
  ["#2b7a0c"] = "var(--magnetic-color-green-45)",
  ["#398519"] = "var(--magnetic-color-green-50)",
  ["#45991f"] = "var(--magnetic-color-green-55)",
  ["#52a62b"] = "var(--magnetic-color-green-60)",
  ["#5eb035"] = "var(--magnetic-color-green-65)",
  ["#6bbf41"] = "var(--magnetic-color-green-70)",
  ["#98d977"] = "var(--magnetic-color-green-80)",
  ["#b0e396"] = "var(--magnetic-color-green-85)",
  ["#c5ebb2"] = "var(--magnetic-color-green-90)",
  ["#e0f5d5"] = "var(--magnetic-color-green-95)",
  ["#000"] = "var(--magnetic-color-neutral-0)",
  ["#0f1214"] = "var(--magnetic-color-neutral-5)",
  ["#23282e"] = "var(--magnetic-color-neutral-15)",
  ["#373c42"] = "var(--magnetic-color-neutral-25)",
  ["#464c54"] = "var(--magnetic-color-neutral-35)",
  ["#596069"] = "var(--magnetic-color-neutral-40)",
  ["#656c75"] = "var(--magnetic-color-neutral-45)",
  ["#6f7680"] = "var(--magnetic-color-neutral-50)",
  ["#7e868f"] = "var(--magnetic-color-neutral-55)",
  ["#889099"] = "var(--magnetic-color-neutral-60)",
  ["#979fa8"] = "var(--magnetic-color-neutral-65)",
  ["#a7adb5"] = "var(--magnetic-color-neutral-70)",
  ["#c1c6cc"] = "var(--magnetic-color-neutral-80)",
  ["#d0d4d9"] = "var(--magnetic-color-neutral-85)",
  ["#e1e4e8"] = "var(--magnetic-color-neutral-90)",
  ["#f0f1f2"] = "var(--magnetic-color-neutral-95)",
  ["#f7f7f7"] = "var(--magnetic-color-neutral-98)",
  ["#fff"] = "var(--magnetic-color-neutral-100)",
  ["#0000"] = "var(--magnetic-color-neutral-transparent)",
  ["#942e03"] = "var(--magnetic-color-orange-35)",
  ["#ad3907"] = "var(--magnetic-color-orange-40)",
  ["#bd410b"] = "var(--magnetic-color-orange-45)",
  ["#c44f14"] = "var(--magnetic-color-orange-50)",
  ["#d95a1a"] = "var(--magnetic-color-orange-55)",
  ["#f26722"] = "var(--magnetic-color-orange-60)",
  ["#f7782f"] = "var(--magnetic-color-orange-65)",
  ["#fc8d4c"] = "var(--magnetic-color-orange-70)",
  ["#fcb88d"] = "var(--magnetic-color-orange-80)",
  ["#fcc9a7"] = "var(--magnetic-color-orange-85)",
  ["#ffd9bf"] = "var(--magnetic-color-orange-90)",
  ["#ffeadb"] = "var(--magnetic-color-orange-95)",
  ["#0051af"] = "var(--magnetic-color-blue-35)",
  ["#0d5cbd"] = "var(--magnetic-color-blue-40)",
  ["#1d69cc"] = "var(--magnetic-color-blue-45)",
  ["#2774d9"] = "var(--magnetic-color-blue-50)",
  ["#3e84e5"] = "var(--magnetic-color-blue-55)",
  ["#5191f0"] = "var(--magnetic-color-blue-60)",
  ["#649ef5"] = "var(--magnetic-color-blue-65)",
  ["#7cadf7"] = "var(--magnetic-color-blue-70)",
  ["#a3c8ff"] = "var(--magnetic-color-blue-80)",
  ["#bad6ff"] = "var(--magnetic-color-blue-85)",
  ["#cce1ff"] = "var(--magnetic-color-blue-90)",
  ["#e3eeff"] = "var(--magnetic-color-blue-95)",
  ["#f0f6ff"] = "var(--magnetic-color-blue-98)",
  ["#3b47b2"] = "var(--magnetic-color-lavender-35)",
  ["#4653c7"] = "var(--magnetic-color-lavender-40)",
  ["#505ed9"] = "var(--magnetic-color-lavender-45)",
  ["#5a68e5"] = "var(--magnetic-color-lavender-50)",
  ["#6977f0"] = "var(--magnetic-color-lavender-55)",
  ["#7d8aff"] = "var(--magnetic-color-lavender-60)",
  ["#8a95ff"] = "var(--magnetic-color-lavender-65)",
  ["#9ca6ff"] = "var(--magnetic-color-lavender-70)",
  ["#bac1ff"] = "var(--magnetic-color-lavender-80)",
  ["#ccd1ff"] = "var(--magnetic-color-lavender-85)",
  ["#d9ddff"] = "var(--magnetic-color-lavender-90)",
  ["#ebedff"] = "var(--magnetic-color-lavender-95)",
  ["#991d53"] = "var(--magnetic-color-pink-35)",
  ["#b02863"] = "var(--magnetic-color-pink-40)",
  ["#c2306f"] = "var(--magnetic-color-pink-45)",
  ["#cf3a7a"] = "var(--magnetic-color-pink-50)",
  ["#e3447c"] = "var(--magnetic-color-pink-55)",
  ["#f2638c"] = "var(--magnetic-color-pink-60)",
  ["#f57398"] = "var(--magnetic-color-pink-65)",
  ["#ff87a9"] = "var(--magnetic-color-pink-70)",
  ["#fcb3c8"] = "var(--magnetic-color-pink-80)",
  ["#ffc4d5"] = "var(--magnetic-color-pink-85)",
  ["#ffd4e0"] = "var(--magnetic-color-pink-90)",
  ["#ffe8ef"] = "var(--magnetic-color-pink-95)",
  ["#425902"] = "var(--magnetic-color-lime-35)",
  ["#4c6605"] = "var(--magnetic-color-lime-40)",
  ["#577309"] = "var(--magnetic-color-lime-45)",
  ["#61800e"] = "var(--magnetic-color-lime-50)",
  ["#6c8c14"] = "var(--magnetic-color-lime-55)",
  ["#7da11b"] = "var(--magnetic-color-lime-60)",
  ["#89ab2c"] = "var(--magnetic-color-lime-65)",
  ["#9dba4c"] = "var(--magnetic-color-lime-70)",
  ["#b5d166"] = "var(--magnetic-color-lime-80)",
  ["#c7de8a"] = "var(--magnetic-color-lime-85)",
  ["#d7e8a9"] = "var(--magnetic-color-lime-90)",
  ["#eaf2d3"] = "var(--magnetic-color-lime-95)",
  ["#005c66"] = "var(--magnetic-color-teal-35)",
  ["#006773"] = "var(--magnetic-color-teal-40)",
  ["#017580"] = "var(--magnetic-color-teal-45)",
  ["#01818c"] = "var(--magnetic-color-teal-50)",
  ["#028e99"] = "var(--magnetic-color-teal-55)",
  ["#04a4b0"] = "var(--magnetic-color-teal-60)",
  ["#0bb2b8"] = "var(--magnetic-color-teal-65)",
  ["#17c2c2"] = "var(--magnetic-color-teal-70)",
  ["#4ad9d9"] = "var(--magnetic-color-teal-80)",
  ["#84e3e3"] = "var(--magnetic-color-teal-85)",
  ["#a9ebeb"] = "var(--magnetic-color-teal-90)",
  ["#d5f5f5"] = "var(--magnetic-color-teal-95)",
  ["#941b76"] = "var(--magnetic-color-magenta-35)",
  ["#a62686"] = "var(--magnetic-color-magenta-40)",
  ["#b53394"] = "var(--magnetic-color-magenta-45)",
  ["#c23ea1"] = "var(--magnetic-color-magenta-50)",
  ["#d649b3"] = "var(--magnetic-color-magenta-55)",
  ["#e85fc6"] = "var(--magnetic-color-magenta-60)",
  ["#f26dd1"] = "var(--magnetic-color-magenta-65)",
  ["#f582d8"] = "var(--magnetic-color-magenta-70)",
  ["#f7b0e5"] = "var(--magnetic-color-magenta-80)",
  ["#fac5ed"] = "var(--magnetic-color-magenta-85)",
  ["#ffd1f3"] = "var(--magnetic-color-magenta-90)",
  ["#ffe8f9"] = "var(--magnetic-color-magenta-95)",
  ["#484f7a"] = "var(--magnetic-color-slate-35)",
  ["#545c8a"] = "var(--magnetic-color-slate-40)",
  ["#5d6596"] = "var(--magnetic-color-slate-45)",
  ["#6871a3"] = "var(--magnetic-color-slate-50)",
  ["#767eb2"] = "var(--magnetic-color-slate-55)",
  ["#868ec2"] = "var(--magnetic-color-slate-60)",
  ["#959ccc"] = "var(--magnetic-color-slate-65)",
  ["#a3aad6"] = "var(--magnetic-color-slate-70)",
  ["#c1c6e8"] = "var(--magnetic-color-slate-80)",
  ["#ced3f2"] = "var(--magnetic-color-slate-85)",
  ["#d9defa"] = "var(--magnetic-color-slate-90)",
  ["#ebedff"] = "var(--magnetic-color-slate-95)",
  ["#075e39"] = "var(--magnetic-color-emerald-35)",
  ["#087041"] = "var(--magnetic-color-emerald-40)",
  ["#0b7b46"] = "var(--magnetic-color-emerald-45)",
  ["#0f874c"] = "var(--magnetic-color-emerald-50)",
  ["#169855"] = "var(--magnetic-color-emerald-55)",
  ["#21a65f"] = "var(--magnetic-color-emerald-60)",
  ["#36b26e"] = "var(--magnetic-color-emerald-65)",
  ["#4cbf7f"] = "var(--magnetic-color-emerald-70)",
  ["#75d9a0"] = "var(--magnetic-color-emerald-80)",
  ["#97e5b8"] = "var(--magnetic-color-emerald-85)",
  ["#b6edcc"] = "var(--magnetic-color-emerald-90)",
  ["#d4f5e1"] = "var(--magnetic-color-emerald-95)",
  ["#015788"] = "var(--magnetic-color-light-blue-35)",
  ["#03639c"] = "var(--magnetic-color-light-blue-40)",
  ["#0570ad"] = "var(--magnetic-color-light-blue-45)",
  ["#087abd"] = "var(--magnetic-color-light-blue-50)",
  ["#0d8bd4"] = "var(--magnetic-color-light-blue-55)",
  ["#139beb"] = "var(--magnetic-color-light-blue-60)",
  ["#23a8eb"] = "var(--magnetic-color-light-blue-65)",
  ["#33bbf5"] = "var(--magnetic-color-light-blue-70)",
  ["#6fd2fc"] = "var(--magnetic-color-light-blue-80)",
  ["#9adffc"] = "var(--magnetic-color-light-blue-85)",
  ["#b5e9ff"] = "var(--magnetic-color-light-blue-90)",
  ["#d9f4ff"] = "var(--magnetic-color-light-blue-95)",
  ["#804103"] = "var(--magnetic-color-yellow-35)",
  ["#944b03"] = "var(--magnetic-color-yellow-40)",
  ["#a65503"] = "var(--magnetic-color-yellow-45)",
  ["#b05f04"] = "var(--magnetic-color-yellow-50)",
  ["#bd7202"] = "var(--magnetic-color-yellow-55)",
  ["#cc8604"] = "var(--magnetic-color-yellow-60)",
  ["#d6900d"] = "var(--magnetic-color-yellow-65)",
  ["#e0a419"] = "var(--magnetic-color-yellow-70)",
  ["#f0c243"] = "var(--magnetic-color-yellow-80)",
  ["#f2d268"] = "var(--magnetic-color-yellow-85)",
  ["#f5e08e"] = "var(--magnetic-color-yellow-90)",
  ["#faefb9"] = "var(--magnetic-color-yellow-95)",
  ["#a01d26"] = "var(--magnetic-color-red-35)",
  ["#b2242d"] = "var(--magnetic-color-red-40)",
  ["#cc2d37"] = "var(--magnetic-color-red-45)",
  ["#d93843"] = "var(--magnetic-color-red-50)",
  ["#eb4651"] = "var(--magnetic-color-red-55)",
  ["#fa5762"] = "var(--magnetic-color-red-60)",
  ["#ff6e72"] = "var(--magnetic-color-red-65)",
  ["#ff878b"] = "var(--magnetic-color-red-70)",
  ["#ffb2b5"] = "var(--magnetic-color-red-80)",
  ["#ffc7c9"] = "var(--magnetic-color-red-85)",
  ["#ffd4d5"] = "var(--magnetic-color-red-90)",
  ["#ffe8e9"] = "var(--magnetic-color-red-95)",
  ["#6732b8"] = "var(--magnetic-color-purple-35)",
  ["#753bcc"] = "var(--magnetic-color-purple-40)",
  ["#864ae0"] = "var(--magnetic-color-purple-45)",
  ["#8d4eed"] = "var(--magnetic-color-purple-50)",
  ["#9b5ff5"] = "var(--magnetic-color-purple-55)",
  ["#a974f7"] = "var(--magnetic-color-purple-60)",
  ["#b587fa"] = "var(--magnetic-color-purple-65)",
  ["#c299ff"] = "var(--magnetic-color-purple-70)",
  ["#d6baff"] = "var(--magnetic-color-purple-80)",
  ["#e0ccff"] = "var(--magnetic-color-purple-85)",
  ["#e8d9ff"] = "var(--magnetic-color-purple-90)",
  ["#f3ebff"] = "var(--magnetic-color-purple-95)",
}

-- TODO: Handle colors?
local px_to_magnetic = {
  ["border"] = {
    ["2px"] = "var(--magnetic-border-width)",
    ["0px"] = "var(--magnetic-border-width-none)",
    ["0"] = "var(--magnetic-border-width-none)",
  },
  ["padding"] = {
    ["0"] = "var(--magnetic-spacing-none)",
    ["4px"] = "var(--magnetic-spacing-xxsmall)",
    ["8px"] = "var(--magnetic-spacing-xsmall)",
    ["12px"] = "var(--magnetic-spacing-small)",
    ["16px"] = "var(--magnetic-spacing-medium)",
    ["24px"] = "var(--magnetic-spacing-large)",
    ["32px"] = "var(--magnetic-spacing-xlarge)",
    ["48px"] = "var(--magnetic-spacing-xxlarge)",
  },
  ["gap"] = {
    ["0"] = "var(--magnetic-spacing-none)",
    ["4px"] = "var(--magnetic-spacing-xxsmall)",
    ["8px"] = "var(--magnetic-spacing-xsmall)",
    ["12px"] = "var(--magnetic-spacing-small)",
    ["16px"] = "var(--magnetic-spacing-medium)",
    ["24px"] = "var(--magnetic-spacing-large)",
    ["32px"] = "var(--magnetic-spacing-xlarge)",
    ["48px"] = "var(--magnetic-spacing-xxlarge)",
  },
  ["margin"] = {
    ["0"] = "var(--magnetic-spacing-none)",
    ["4px"] = "var(--magnetic-spacing-xxsmall)",
    ["8px"] = "var(--magnetic-spacing-xsmall)",
    ["12px"] = "var(--magnetic-spacing-small)",
    ["16px"] = "var(--magnetic-spacing-medium)",
    ["24px"] = "var(--magnetic-spacing-large)",
    ["32px"] = "var(--magnetic-spacing-xlarge)",
    ["48px"] = "var(--magnetic-spacing-xxlarge)",
  },
  ["border-radius"] = {
    ["0"] = "var(--magnetic-border-radius-none)",
    ["6px"] = "var(--magnetic-border-radius-s)",
    ["8px"] = "var(--magnetic-border-radius-md)",
    ["11px"] = "var(--magnetic-border-radius-lg)",
    ["17px"] = "var(--magnetic-border-radius-xl)",
    ["9999px"] = "var(--magnetic-border-radius-pill)",
    -- ["50%"] = "var(--magnetic-border-radius-circle)",
    -- This breaks us. Fixable but I'm not sure where? Error happens on safe-replace
  },
  ["border-width"] = {
    ["2px"] = "var(--magnetic-border-width)",
  },
  ["font-size"] = {
    ["24px"] = "var(--magnetic-font-size-primary-title)",
    ["18px"] = "var(--magnetic-font-size-section-title)",
    ["16px"] = "var(--magnetic-font-size-sub-section-title)",
    ["14px"] = "var(--magnetic-font-size-smallest-title)",
    ["12px"] = "var(--magnetic-font-size-p4)",
  },
  ["line-height"] = {
    ["34px"] = "var(--magnetic-font-line-height-primary-title)",
    ["24px"] = "var(--magnetic-font-line-height-section-title)",
    ["22px"] = "var(--magnetic-font-line-height-sub-section-title)",
    ["20px"] = "var(--magnetic-font-line-height-smallest-title)",
    ["18px"] = "var(--magnetic-font-line-height-p4)",
  },
  ["font-weight"] = {
    ["700"] = "var(--magnetic-font-weight-bold)",
    ["600"] = "var(--magnetic-font-weight-semibold)",
    ["400"] = "var(--magnetic-font-weight-regular)",
  },
  ["color"] = mag_colors,
  ["background"] = mag_colors,
  ["fill"] = mag_colors,
  ["stroke"] = mag_colors,
}

-- TODO: Make fake variable names for the mag values?
-- -- (Although, that doesn't work for existing mag values.)
-- -- We need a way to use the right property.
-- -- i.e. we painted ourselves into a corner simplifying the mag to base with colors
local magnetic_to_base = {
  ["var(--magnetic-color-neutral-90)"] = "var(--base-border-default)",
  ["var(--magnetic-color-neutral-98)"] = "var(--base-bg-default)",
  ["var(--magnetic-color-red-95)"] = "var(--negative-bg-medium-default)",
  ["var(--magnetic-color-red-45)"] = "var(--negative-bg-default)",
  ["var(--magnetic-color-yellow-95)"] = "var(--warning-bg-medium-default)",
  ["var(--magnetic-color-yellow-60)"] = "var(--warning-bg-default)",
  ["var(--magnetic-color-purple-95)"] = "var(--info-bg-medium-default)",
  ["var(--magnetic-color-purple-45)"] = "var(--info-bg-default)",
  ["var(--magnetic-color-neutral-15)"] = "var(--base-text-default)",
  ["var(--magnetic-color-blue-45)"] = "var(--interact-text-default)",
  ["var(--magnetic-spacing-none)"] = "var(--base-spacing-none)",
  ["var(--magnetic-spacing-xxsmall)"] = "var(--base-spacing-xxsmall)",
  ["var(--magnetic-spacing-xsmall)"] = "var(--base-spacing-xsmall)",
  ["var(--magnetic-spacing-small)"] = "var(--base-spacing-small)",
  ["var(--magnetic-spacing-medium)"] = "var(--base-spacing-medium)",
  ["var(--magnetic-spacing-large)"] = "var(--base-spacing-large)",
  ["var(--magnetic-spacing-xlarge)"] = "var(--base-spacing-xlarge)",
  ["var(--magnetic-spacing-xxlarge)"] = "var(--base-spacing-xxlarge)",
  ["var(--magnetic-border-radius-none)"] = "var(--base-border-radius-none)",
  ["var(--magnetic-border-radius-s)"] = "var(--base-border-radius-s)",
  ["var(--magnetic-border-radius-md)"] = "var(--base-border-radius-md)",
  ["var(--magnetic-border-radius-lg)"] = "var(--base-border-radius-lg)",
  ["var(--magnetic-border-radius-xl)"] = "var(--base-border-radius-xl)",
  ["var(--magnetic-border-radius-pill)"] = "var(--base-border-radius-pill)",
  ["var(--magnetic-border-radius-circle)"] = "var(--base-border-radius-circle)",
  ["var(--magnetic-border-width)"] = "var(--base-border-width)",
  ["var(--magnetic-font-size-primary-title)"] = "var(--base-font-size-primary-title)",
  ["var(--magnetic-font-size-section-title)"] = "var(--base-font-size-section-title)",
  ["var(--magnetic-font-size-sub-section-title)"] = "var(--base-font-size-sub-section-title)",
  ["var(--magnetic-font-size-smallest-title)"] = "var(--base-font-size-smallest-title)",
  ["var(--magnetic-font-size-p1)"] = "var(--base-font-size-p1)",
  ["var(--magnetic-font-size-p2)"] = "var(--base-font-size-p2)",
  ["var(--magnetic-font-size-p3)"] = "var(--base-font-size-p3)",
  ["var(--magnetic-font-size-p4)"] = "var(--base-font-size-p4)",
  ["var(--magnetic-font-line-height-primary-title)"] = "var(--base-font-line-height-primary-title)",
  ["var(--magnetic-font-line-height-section-title)"] = "var(--base-font-line-height-section-title)",
  ["var(--magnetic-font-line-height-sub-section-title)"] = "var(--base-font-line-height-sub-section-title)",
  ["var(--magnetic-font-line-height-smallest-title)"] = "var(--base-font-line-height-smallest-title)",
  ["var(--magnetic-font-line-height-p1)"] = "var(--base-font-line-height-p1)",
  ["var(--magnetic-font-line-height-p2)"] = "var(--base-font-line-height-p2)",
  ["var(--magnetic-font-line-height-p3)"] = "var(--base-font-line-height-p3)",
  ["var(--magnetic-font-line-height-p4)"] = "var(--base-font-line-height-p4)",
  ["var(--magnetic-font-weight-bold)"] = "var(--base-font-weight-bold)",
  ["var(--magnetic-font-weight-semibold)"] = "var(--base-font-weight-semibold)",
  ["var(--magnetic-font-weight-regular)"] = "var(--base-font-weight-regular)",
}

-- Table to convert magnetic variables to base variables
function _G.ReplaceCSSValues()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  lines = replace_values(lines, px_to_magnetic)
  lines = replace_magnetic_values(lines, magnetic_to_base)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

-- Create a user command
vim.api.nvim_create_user_command("Mag", function()
  ReplaceCSSValues()
end, {})

vim.api.nvim_create_user_command("Mi", function()
  TestMigrationScript()
end, {})
