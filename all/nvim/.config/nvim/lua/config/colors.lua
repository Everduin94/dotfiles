local M = {}

-- Colorschemes we can switch between. `M.toggle()` flips catppuccin <-> kanso.
-- Change `kanso_variant` to "zen" | "ink" | "mist" | "pearl" (pearl is light).
local kanso_variant = "ink"
local primary = "catppuccin"
local secondary = "kanso-" .. kanso_variant

local choices = { "catppuccin", "kanso-zen", "kanso-ink", "kanso-mist", "kanso-pearl" }
local state_file = vim.fn.stdpath("state") .. "/colorscheme"

---------------------------------------------------------------------------
-- catppuccin
---------------------------------------------------------------------------
require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
})

---------------------------------------------------------------------------
-- kanso
---------------------------------------------------------------------------
-- `transparent = false` on purpose: kanso paints its own (cool, dark) bg so it
-- doesn't clash with the Ghostty theme bg. Window see-through is handled by the
-- terminal (`:TermOpacity` / <leader>uT) since Ghostty has
-- `background-opacity-cells = true`, which applies to painted cells too.
-- Set to true to let the terminal bg show through instead.
--
-- RESEARCH / OFF BY DEFAULT: "reserved" syntax, ported from my archived
-- catppuccin "Minimal Theme Implementation"
-- (archive/nvim-lazyvim-2026-07-04/.config/nvim/lua/modules/ui/ui-commands.lua).
-- Idea: only a few things get color (declarations, literals, functions);
-- types / members / params / builtins collapse to fg, punctuation to a softer
-- fg. Catppuccin -> kanso mapping used below:
--   text     #cdd6f4 -> theme.ui.fg
--   subtext  #bac2de -> theme.syn.punct  (gray3)
--   blue     #89b4fa -> palette.blue3    (declarations)
--   lavender #b4befe -> palette.violet3  (function calls)
--   teal     #94e2d5 -> palette.green5   (string/number/boolean)
--   rosewater#f5e0dc -> palette.pink     (keywords, italic)
--   pink     #f5c2e7 -> palette.pink     (param declarations)
-- To turn on: uncomment `reserved` and the `overrides = reserved` line below.
-- To port to another theme: same group list, swap the color lookups for that
-- theme's palette (catppuccin uses `custom_highlights = function(c) ... end`).
--
-- local reserved = function(colors)
--   local t, p = colors.theme, colors.palette
--   local fg, soft = t.ui.fg, t.syn.punct
--   local decl = p.blue3
--   local kw = { fg = p.pink, italic = true }
--   return {
--     -- white-ish: no color for types / members / params / builtins
--     Type = { fg = fg },
--     ["@type.builtin"] = { fg = fg },
--     ["@function.builtin"] = { fg = fg },
--     ["@variable.member"] = { fg = fg },
--     ["@variable.parameter"] = { fg = fg },
--     ["@variable.builtin"] = { fg = fg, italic = true },
--     ["@property"] = { fg = fg },
--     ["@lsp.typemod.property.declaration.typescript"] = { fg = fg },
--     -- function calls
--     Function = { fg = p.violet3 },
--     -- declarations pop (LSP semantic tokens beat treesitter)
--     ["@lsp.mod.declaration.typescript"] = { fg = decl },
--     ["@lsp.typemod.variable.declaration.svelte"] = { fg = decl },
--     ["@lsp.typemod.function.declaration.svelte"] = { fg = decl },
--     ["@constructor.typescript"] = { fg = decl },
--     ["@lsp.typemod.parameter.declaration.typescript"] = { fg = p.pink },
--     ["@lsp.typemod.parameter.declaration.svelte"] = { fg = p.pink },
--     -- quiet punctuation / operators
--     Operator = { fg = soft },
--     Special = { fg = soft },
--     Delimiter = { fg = soft },
--     ["@punctuation.bracket"] = { fg = soft },
--     MatchParen = { fg = p.pink, bg = "NONE" },
--     -- literals share one color
--     String = { fg = p.green5 },
--     Number = { fg = p.green5 },
--     Boolean = { fg = p.green5 },
--     -- keywords: soft + italic
--     Keyword = kw,
--     Exception = kw,
--     Conditional = kw,
--     Include = kw,
--     ["@keyword.function"] = kw,
--     ["@keyword.export"] = kw,
--     ["@keyword.operator"] = kw,
--     ["@keyword.return"] = kw,
--   }
-- end
--
-- Smaller built-in alternative: `minimal = true` (kanso's own reduced palette).
require("kanso").setup({
  transparent = false,
  -- overrides = reserved,
  -- minimal = true,
})

---------------------------------------------------------------------------
-- switching
---------------------------------------------------------------------------
local function read_state()
  local ok, lines = pcall(vim.fn.readfile, state_file)
  local name = ok and lines[1] or nil
  if name and vim.tbl_contains(choices, name) then
    return name
  end
end

local function write_state(name)
  pcall(vim.fn.mkdir, vim.fn.fnamemodify(state_file, ":h"), "p")
  pcall(vim.fn.writefile, { name }, state_file)
end

function M.current()
  if vim.g.colors_name == "kanso" then
    return "kanso-" .. (require("kanso")._CURRENT_THEME or kanso_variant)
  end
  if vim.g.colors_name and vim.g.colors_name:find("^catppuccin") then
    return "catppuccin"
  end
  return vim.g.colors_name
end

function M.set(name, opts)
  opts = opts or {}
  if not vim.tbl_contains(choices, name) then
    vim.notify("Unknown colorscheme: " .. tostring(name), vim.log.levels.ERROR)
    return
  end

  vim.o.background = name == "kanso-pearl" and "light" or "dark"

  local ok, err = pcall(vim.cmd.colorscheme, name)
  if not ok then
    vim.notify("Colorscheme failed: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  if not opts.silent then
    write_state(name)
    vim.notify("Colorscheme: " .. name)
  end
end

function M.toggle()
  M.set(M.current() == primary and secondary or primary)
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

vim.keymap.set("n", "<leader>ut", M.toggle, { desc = "Toggle colorscheme (catppuccin/kanso)" })

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

M.set(read_state() or primary, { silent = true })

return M
