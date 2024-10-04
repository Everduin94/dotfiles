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
}

-- Function to find CSS property from a string
local function findCssProperty(str)
  for _, property in ipairs(validProperties) do
    if str:match(property) then
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

-- TODO: Handle colors?
-- Add Gap
-- Add Border
local px_to_magnetic = {
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
    ["50%"] = "var(--magnetic-border-radius-circle)",
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
}

local magnetic_to_base = {
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
