local M = {}

-- <leader>ut toggles between the default and the last other scheme you picked,
-- <leader>uc picks with live preview, <leader>un / <leader>uN step through.
-- The last scheme used is saved in stdpath("state") and wins over `primary`.
local primary = "tokyonight-moon-minimal"
local default_alt = "catppuccin"

local choices = {
  "tokyonight-moon-minimal",
  "tokyonight-night-minimal",
  "kanagawa-minimal",
  "kanagawa-dragon-minimal",
  "catppuccin",
  "nightfox",
}

local state_dir = vim.fn.stdpath("state")
local state_file = state_dir .. "/colorscheme"
local alt_file = state_dir .. "/colorscheme-alt"
local secondary = default_alt

require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
})

---------------------------------------------------------------------------
-- *-minimal
---------------------------------------------------------------------------
-- Most code is plain fg. A thing gets color where it's declared, not where
-- it's used. Types are the exception and keep one color everywhere.
--
-- Each theme maps its palette onto these slots (kanagawa_ladder,
-- tokyonight_ladder):
--   decl      functions, methods, variables, and types being declared
--   type      type references and classes in `new X()`
--   literal   strings, numbers, booleans, null / nil
--   param     parameter declarations
--   keyword   keywords
--   soft      punctuation and operators
--   fg        everything else, including calls and usages
--   cursor_nr current line number
local function hex_mix(a, b, t)
  local function rgb(h)
    return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
  end
  local ar, ag, ab = rgb(a)
  local br, bg, bb = rgb(b)
  local function m(x, y)
    return math.floor(x + (y - x) * t + 0.5)
  end
  return string.format("#%02x%02x%02x", m(ar, br), m(ag, bg), m(ab, bb))
end

-- Flags for the minimal themes, saved in stdpath("state"):
--   <leader>uy  types in plain fg
--   <leader>up  parameter declarations in the line number blue
--   <leader>uk  keywords in a dim grey, so they step back
local flags = {
  white_types = { key = "<leader>uy", desc = "white types" },
  blue_params = { key = "<leader>up", desc = "blue params" },
  muted_keywords = { key = "<leader>uk", desc = "muted keywords" },
}
local function flag_file(name)
  return vim.fn.stdpath("state") .. "/minimal-" .. name:gsub("_", "-")
end
for name, flag in pairs(flags) do
  local ok, lines = pcall(vim.fn.readfile, flag_file(name))
  flag.on = ok and lines[1] == "on"
end

---@param c { fg: string, bg: string, soft: string, decl: string, type: string, literal: string, param: string, keyword: string, cursor_nr: string, on_accent: string }
local function minimal(c)
  local decl = { fg = c.decl }
  local type = { fg = flags.white_types.on and c.fg or c.type }
  local literal = { fg = c.literal }
  local param = { fg = flags.blue_params.on and c.cursor_nr or c.param }
  local muted = 0.38 -- how far muted keywords move toward the bg
  local keyword = flags.muted_keywords.on and { fg = hex_mix(c.fg, c.bg, muted), italic = false }
    or { fg = c.keyword, italic = true }
  local plain = { fg = c.fg }
  local quiet = { fg = c.soft }
  local none = {}

  return {
    -- usages
    Identifier = plain,
    Constant = plain,
    ["@variable"] = plain,
    ["@variable.member"] = plain,
    ["@variable.parameter"] = plain,
    ["@variable.builtin"] = { fg = c.fg, italic = true },
    ["@property"] = plain,
    ["@constant"] = plain,
    ["@module"] = plain,
    ["@string.special.symbol"] = plain,
    ["@function.call"] = plain,
    ["@function.method.call"] = plain,
    ["@function.builtin"] = plain,
    ["@lsp.type.variable"] = plain,
    ["@lsp.type.property"] = plain,
    ["@lsp.type.parameter"] = plain,
    ["@lsp.type.function"] = plain,
    ["@lsp.type.method"] = plain,
    ["@lsp.type.member"] = plain, -- ts_ls methods
    ["@lsp.type.namespace"] = plain,
    ["@lsp.type.enumMember"] = plain,
    -- `declaration` on its own also marks object keys
    ["@lsp.mod.declaration"] = none,
    ["@lsp.typemod.property.declaration"] = none,

    -- declarations (LSP typemods outrank the usage colors above)
    Function = decl,
    ["@function"] = decl,
    ["@function.method"] = decl,
    ["@type.definition"] = decl,
    ["@lsp.typemod.function.declaration"] = decl,
    ["@lsp.typemod.method.declaration"] = decl,
    ["@lsp.typemod.member.declaration"] = decl,
    ["@lsp.typemod.variable.declaration"] = decl,
    ["@lsp.typemod.class.declaration"] = decl,
    ["@lsp.typemod.interface.declaration"] = decl,
    ["@lsp.typemod.type.declaration"] = decl,
    ["@lsp.typemod.typeAlias.declaration"] = decl,
    ["@lsp.typemod.enum.declaration"] = decl,

    -- types
    Type = type,
    ["@type"] = type,
    ["@type.builtin"] = type,
    ["@constructor"] = type,
    ["@lsp.type.class"] = type,
    ["@lsp.type.interface"] = type,
    ["@lsp.type.type"] = type,
    ["@lsp.type.typeAlias"] = type,
    ["@lsp.type.enum"] = type,
    ["@lsp.type.struct"] = type,
    ["@lsp.type.typeParameter"] = type,
    ["@lsp.type.builtinType"] = type,

    -- literals
    String = literal,
    Character = literal,
    Number = literal,
    Float = literal,
    Boolean = literal,
    ["@constant.builtin"] = literal,

    ["@lsp.typemod.parameter.declaration"] = param,
    MatchParen = { fg = param.fg, bold = true },

    -- keywords
    Statement = keyword,
    Keyword = keyword,
    Conditional = keyword,
    Repeat = keyword,
    Label = keyword,
    Exception = keyword,
    Include = keyword,
    PreProc = keyword,
    ["@attribute"] = keyword,
    ["@lsp.type.decorator"] = keyword,
    ["@keyword"] = keyword,
    ["@keyword.function"] = keyword,
    ["@keyword.return"] = keyword,
    ["@keyword.exception"] = keyword,
    ["@keyword.import"] = keyword,
    ["@keyword.export"] = keyword,
    ["@keyword.operator"] = keyword,
    ["@keyword.conditional"] = keyword,
    ["@keyword.repeat"] = keyword,
    ["@keyword.coroutine"] = keyword,
    ["@keyword.modifier"] = keyword,
    ["@keyword.type"] = keyword,
    ["@lsp.type.keyword"] = keyword,

    -- punctuation and operators
    Operator = quiet,
    Special = quiet,
    Delimiter = quiet,
    ["@operator"] = quiet,
    ["@punctuation.bracket"] = quiet,
    ["@punctuation.delimiter"] = quiet,
    ["@punctuation.special"] = quiet,
    ["@constructor.lua"] = quiet, -- lua table braces

    CursorLineNr = { fg = c.cursor_nr, bold = true },
    MiniStatuslineModeInsert = { fg = c.on_accent, bg = c.literal, bold = true },

    -- markdown; markview builds its heading colors from these
    ["@markup.heading"] = { fg = c.decl, bold = true },
    ["@markup.heading.1.markdown"] = { fg = c.decl, bold = true },
    ["@markup.heading.2.markdown"] = { fg = c.type, bold = true },
    ["@markup.heading.3.markdown"] = { fg = c.literal, bold = true },
    ["@markup.heading.4.markdown"] = { fg = c.param, bold = true },
    ["@markup.heading.5.markdown"] = { fg = c.keyword, bold = true },
    ["@markup.heading.6.markdown"] = { fg = c.soft, bold = true },
    ["@markup.raw.markdown_inline"] = literal,
  }
end

-- Other LSP modifiers (readonly, local, defaultLibrary, ...) share the
-- priority of `declaration` and would recolor it; in tokyonight every TS
-- `const` turns orange. After a minimal scheme loads, drop their fg unless
-- minimal() sets it. Style-only groups like the deprecated strikethrough stay.
local minimal_keys = vim.tbl_keys(minimal(setmetatable({}, {
  __index = function()
    return "#000000"
  end,
})))
local function strip_lsp_modifier_colors()
  local keep = {}
  for _, k in ipairs(minimal_keys) do
    keep[k] = true
  end
  for name in pairs(vim.api.nvim_get_hl(0, {})) do
    if (name:find("^@lsp%.mod%.") or name:find("^@lsp%.typemod%.")) and not keep[name] then
      local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
      if hl.fg then
        hl.fg = nil
        vim.api.nvim_set_hl(0, name, hl)
      end
    end
  end
end

local function kanagawa_ladder(colors)
  local p, t = colors.palette, colors.theme
  return {
    fg = t.ui.fg,
    bg = t.ui.bg,
    soft = p.oldWhite,
    decl = p.carpYellow,
    type = p.springBlue,
    literal = p.springGreen,
    param = p.sakuraPink,
    keyword = p.springViolet1,
    cursor_nr = p.springBlue,
    on_accent = t.ui.bg,
  }
end

local function kanagawa_minimal(colors)
  return minimal(kanagawa_ladder(colors))
end

-- Uses tokyonight's pink, light blue, and teal. Moon's `purple` is pink;
-- night has no pink, so it uses `red`.
local function tokyonight_ladder(c, pink)
  return {
    fg = c.fg,
    bg = c.bg,
    soft = hex_mix(c.fg_dark, c.blue5, 0.3),
    decl = pink,
    type = c.cyan,
    literal = c.green1,
    param = c.yellow,
    keyword = c.blue,
    cursor_nr = c.blue1,
    on_accent = c.black,
  }
end

local function tokyonight_minimal(pink_key)
  return function(hl, c)
    for group, spec in pairs(minimal(tokyonight_ladder(c, c[pink_key]))) do
      hl[group] = spec
    end
  end
end

-- setup() merges, so re-run it with fresh hooks on every switch.
local variants = {
  ["kanagawa-minimal"] = { base = "kanagawa-wave", overrides = kanagawa_minimal },
  ["kanagawa-dragon-minimal"] = { base = "kanagawa-dragon", overrides = kanagawa_minimal },
  ["tokyonight-moon-minimal"] = { base = "tokyonight-moon", on_highlights = tokyonight_minimal("purple") },
  ["tokyonight-night-minimal"] = { base = "tokyonight-night", on_highlights = tokyonight_minimal("red") },
}

local function setup_theme(variant)
  if variant.overrides then
    require("kanagawa").setup({ overrides = variant.overrides })
  elseif variant.on_highlights then
    require("tokyonight").setup({ on_highlights = variant.on_highlights })
  end
end

---------------------------------------------------------------------------
-- switching
---------------------------------------------------------------------------
local function read_file(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  local name = ok and lines[1] or nil
  if name and vim.tbl_contains(choices, name) then
    return name
  end
end

local function write_file(path, name)
  pcall(vim.fn.mkdir, state_dir, "p")
  pcall(vim.fn.writefile, { name }, path)
end

local current

function M.current()
  return current or vim.g.colors_name
end

function M.set(name, opts)
  opts = opts or {}
  if not vim.tbl_contains(choices, name) then
    vim.notify("Unknown colorscheme: " .. tostring(name), vim.log.levels.ERROR)
    return false
  end

  vim.o.background = "dark"
  local variant = variants[name]
  if variant then
    setup_theme(variant)
  end

  local ok, err = pcall(vim.cmd.colorscheme, variant and variant.base or name)
  if not ok then
    vim.notify("Colorscheme failed: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  current = name
  if variant then
    strip_lsp_modifier_colors()
  end

  if not opts.silent then
    write_file(state_file, name)
    if name ~= primary then
      secondary = name
      write_file(alt_file, name)
    end
    vim.notify("Colorscheme: " .. name)
  end
  return true
end

function M.toggle()
  M.set(M.current() == primary and secondary or primary)
end

local function step(delta)
  local idx = 1
  for i, name in ipairs(choices) do
    if name == M.current() then
      idx = i
    end
  end
  M.set(choices[(idx - 1 + delta) % #choices + 1])
end

--- Pick a scheme with live preview. Esc restores the previous one.
function M.pick()
  local original = M.current()
  if not (_G.Snacks and Snacks.picker) then
    vim.ui.select(choices, { prompt = "Colorscheme" }, function(name)
      if name then
        M.set(name)
      end
    end)
    return
  end

  local items = {}
  for i, name in ipairs(choices) do
    items[i] = { idx = i, text = name .. (name == original and "  (current)" or ""), name = name }
  end

  local confirmed = false
  Snacks.picker.pick({
    title = "Colorscheme",
    items = items,
    format = "text",
    layout = { preset = "select" },
    on_change = function(_, item)
      if item then
        M.set(item.name, { silent = true })
      end
    end,
    confirm = function(picker, item)
      confirmed = true
      picker:close()
      if item then
        vim.schedule(function()
          M.set(item.name)
        end)
      end
    end,
    on_close = function()
      if not confirmed then
        vim.schedule(function()
          M.set(original, { silent = true })
        end)
      end
    end,
  })
end

vim.api.nvim_create_user_command("Theme", function(opts)
  if opts.args == "" then
    M.toggle()
  else
    M.set(opts.args)
  end
end, {
  nargs = "?",
  complete = function()
    return choices
  end,
  desc = "Toggle (no arg) or set the colorscheme",
})

vim.keymap.set("n", "<leader>ut", M.toggle, { desc = "Toggle default / last colorscheme" })
vim.keymap.set("n", "<leader>uc", M.pick, { desc = "Pick colorscheme (live preview)" })
vim.keymap.set("n", "<leader>un", function()
  step(1)
end, { desc = "Next colorscheme" })
vim.keymap.set("n", "<leader>uN", function()
  step(-1)
end, { desc = "Previous colorscheme" })

function M.toggle_flag(name)
  local flag = flags[name]
  flag.on = not flag.on
  pcall(vim.fn.writefile, { flag.on and "on" or "off" }, flag_file(name))
  if variants[M.current() or ""] then
    M.set(M.current(), { silent = true })
  end
  vim.notify("Minimal " .. flag.desc .. ": " .. (flag.on and "on" or "off"))
end

for name, flag in pairs(flags) do
  vim.keymap.set("n", flag.key, function()
    M.toggle_flag(name)
  end, { desc = "Toggle " .. flag.desc .. " (minimal themes)" })
end
vim.api.nvim_create_user_command("MinimalFlag", function(opts)
  M.toggle_flag(opts.args)
end, {
  nargs = 1,
  complete = function()
    return vim.tbl_keys(flags)
  end,
  desc = "Toggle a minimal-theme flag",
})

---------------------------------------------------------------------------
-- terminal (Ghostty) transparency
---------------------------------------------------------------------------
local opacity_script = vim.fn.stdpath("config") .. "/bin/ghostty-opacity"

vim.api.nvim_create_user_command("TermOpacity", function(opts)
  local args = opts.args ~= "" and { opts.args } or {}
  local out = vim.system(vim.list_extend({ opacity_script }, args), { text = true }):wait()
  local msg = vim.trim((out.stdout or "") .. (out.stderr or ""))
  vim.notify(msg ~= "" and msg or "ghostty-opacity", out.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
end, {
  nargs = "?",
  complete = function()
    return { "toggle", "on", "off" }
  end,
  desc = "Toggle Ghostty window transparency (toggle|on|off)",
})

vim.keymap.set("n", "<leader>uT", "<cmd>TermOpacity toggle<cr>", { desc = "Toggle terminal transparency" })

secondary = read_file(alt_file) or default_alt
M.set(read_file(state_file) or primary, { silent = true })

return M
