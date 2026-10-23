local M = {}

-- Renders markdown files and the CodeCompanion chat. Insert mode shows raw text.
-- <leader>um opens a side-by-side preview, <leader>uM turns rendering off.

-- A markview heading preset: slanted, glow, simple, marker, arrowed, numbered
local heading_style = "slanted"

-- Code block bg relative to the dark panel bg: negative is darker, positive is
-- lighter. Close to 0, blocks disappear inside the chat.
local code_shade = -0.2

-- markview pads `block` style code blocks but not `simple` ones, which it uses
-- in wrapping windows like the chat.
local simple_pad = "  "

-- Bar down the left of code blocks (<leader>uB). markview has no option for
-- it, so render_code_block adds it. The gap is the empty part of the `▎` cell.
local code_bar = "▎"
local code_bar_gap = ""
local code_bar_from = "@markup.heading.2.markdown"
local bar_file = vim.fn.stdpath("state") .. "/markview-code-bar"
local bar_on = (function()
  local ok, lines = pcall(vim.fn.readfile, bar_file)
  return not (ok and lines[1] == "off")
end)()

local function get_hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

local function mix(a, b, t)
  local out = 0
  for _, shift in ipairs({ 16, 8, 0 }) do
    local x, y = math.floor(a / 2 ^ shift) % 256, math.floor(b / 2 ^ shift) % 256
    out = out + math.floor(x + (y - x) * t + 0.5) * 2 ^ shift
  end
  return out
end

local function headings()
  local preset = vim.deepcopy(require("markview.presets").headings[heading_style])
  if heading_style == "slanted" then
    -- otherwise markview merges its default icons back in
    for level = 1, 6 do
      preset["heading_" .. level].icon = ""
    end
  end
  return preset
end

-- Runs after markview sets its own highlights.
local function apply_highlights()
  local normal = get_hl("Normal")
  local dark = require("config.panels").dark_bg()
  if dark and normal.fg then
    local bg = code_shade < 0 and mix(dark, 0, -code_shade) or mix(dark, normal.fg, code_shade)
    vim.api.nvim_set_hl(0, "MarkviewCode", { bg = bg })
    vim.api.nvim_set_hl(0, "MarkviewCodeInfo", { fg = get_hl("Comment").fg, bg = bg })
    vim.api.nvim_set_hl(0, "MarkviewCodeFg", { fg = bg })
    -- the language label uses MarkviewIcon<N>, built from the old bg
    for n = 0, 6 do
      local name = "MarkviewIcon" .. n
      local icon = get_hl(name)
      if next(icon) then
        icon.bg = bg
        vim.api.nvim_set_hl(0, name, icon)
      end
    end
    -- The gap needs an explicit bg; `Normal` counts as none and the code line
    -- bg shows through. Dark panels remap this group (panels.lua).
    local bar_fg = get_hl(code_bar_from).fg or get_hl("Special").fg
    vim.api.nvim_set_hl(0, "MarkviewCodeBar", { fg = bar_fg, bg = normal.bg })
    vim.api.nvim_set_hl(0, "MarkviewCodeBarPanel", { fg = bar_fg, bg = dark })
  end
  local raw = get_hl("@markup.raw.markdown_inline").fg or get_hl("@markup.raw").fg or get_hl("String").fg
  vim.api.nvim_set_hl(0, "MarkviewInlineCode", { fg = raw, italic = true })
end

-- Uses markview's namespace so the bar clears with the block.
local function render_code_block(buffer, item)
  local md = require("markview.renderers.markdown")
  md.code_block(buffer, item)

  local win = vim.fn.win_findbuf(buffer)[1]
  local simple = vim.o.wrap or (win ~= nil and vim.wo[win].wrap)

  local chunks = {}
  if bar_on then
    table.insert(chunks, { code_bar, "MarkviewCodeBar" })
    if code_bar_gap ~= "" then
      table.insert(chunks, { code_bar_gap, "MarkviewCodeBar" })
    end
  end
  if simple and simple_pad ~= "" then
    table.insert(chunks, { simple_pad, "MarkviewCode" })
  end
  if #chunks == 0 then
    return
  end

  local range = item.range
  for row = range.row_start, range.row_end - 1 do
    pcall(vim.api.nvim_buf_set_extmark, buffer, md.ns, row, range.col_start, {
      undo_restore = false,
      invalidate = true,
      virt_text = chunks,
      virt_text_pos = "inline",
      right_gravity = false,
    })
  end
end

function M.setup()
  require("markview").setup({
    renderers = {
      markdown_code_block = render_code_block,
    },
    markdown = {
      headings = headings(),
    },
    markdown_inline = {
      inline_codes = { padding_left = "", padding_right = "" },
    },
    preview = {
      filetypes = { "markdown", "codecompanion" },
      -- the chat is a nofile buffer
      ignore_buftypes = {},
      icon_provider = "internal",
    },
  })

  vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
    group = vim.api.nvim_create_augroup("config_markview", { clear = true }),
    callback = apply_highlights,
  })
  apply_highlights()

  local function toggle_bar()
    bar_on = not bar_on
    pcall(vim.fn.writefile, { bar_on and "on" or "off" }, bar_file)
    vim.cmd("Markview Render")
    vim.notify("Code block bar: " .. (bar_on and "on" or "off"))
  end
  vim.keymap.set("n", "<leader>uB", toggle_bar, { desc = "Toggle code block left bar" })
  vim.api.nvim_create_user_command("MarkviewCodeBar", toggle_bar, { desc = "Toggle code block left bar" })

  vim.keymap.set("n", "<leader>um", "<cmd>Markview splitToggle<cr>", { desc = "Markdown side-by-side preview" })
  vim.keymap.set("n", "<leader>uM", "<cmd>Markview Toggle<cr>", { desc = "Toggle markdown rendering" })
end

return M
