local M = {}

M.rose_pine_options = {
  --- @usage 'auto'|'main'|'moon'|'dawn'
  variant = "moon",
  --- @usage 'main'|'moon'|'dawn'
  dark_variant = "main",
  bold_vert_split = false,
  dim_nc_background = false,
  disable_background = true,
  disable_float_background = true,
  disable_italics = false,
  styles = {
    bold = false,
    italic = true,
    transparency = true,
  },
}

M.catppuccin_options = {
  flavour = "mocha", -- latte, frappe, macchiato, mocha
  background = {
    light = "latte",
    dark = "mocha",
  },
  transparent_background = os.getenv("NVIM_TRANSPARENT") == "1",
  show_end_of_buffer = false,
  term_colors = true,
  dim_inactive = {
    enabled = false,
    shade = "dark",
    percentage = 0.15,
  },
  no_italic = false,
  no_bold = false,
  no_underline = false,
  styles = {
    comments = { "italic" },
    conditionals = { "italic" },
    loops = {},
    functions = {},
    keywords = {},
    strings = {},
    variables = {},
    numbers = {},
    booleans = {},
    properties = {},
    types = {},
    operators = {},
  },
  custom_highlights = function(colors)
    return {
      TabLineSel = { bg = colors.pink },
      CmpBorder = { fg = colors.surface2 },
      Number = { fg = colors.sapphire },
      Constant = { fg = colors.sapphire },
      Boolean = { fg = colors.yellow },
      String = { fg = colors.teal },
      ["Type"] = { fg = colors.yellow },
      ["@parameter"] = { fg = colors.sky },
      ["@property"] = { fg = colors.text },
      ["@constant"] = { fg = colors.sapphire },
      ["@constant.builtin"] = { fg = colors.sapphire },
      ["@function.builtin"] = { fg = colors.sapphire },
      ["@variable.builtin"] = { fg = colors.pink },
      ["@method.call"] = { fg = colors.pink },
      ["@number.css"] = { fg = colors.sapphire },
      ["@text.strong"] = { fg = colors.pink },
      ["@type.builtin"] = { fg = colors.teal },
      ["@keyword.function"] = { fg = colors.pink },
      ["@keyword.return"] = { fg = colors.pink },
      ["@keyword.end"] = { fg = colors.pink },
    }
  end,

  integrations = {
    cmp = true,
    gitsigns = true,
    nvimtree = true,
    treesitter = true,
    notify = false,
    mini = false,
    telescope = true,
    lsp_trouble = true,
    which_key = true,
  },
}

M.treesitter_ensure_installed = {
  "bash",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "tsx",
  "typescript",
  "vim",
  "yaml",
  "svelte",
  "css",
}

M.lualine_options = function()
  local SubMode = require("modules.sub_mode.sub_mode")

  vim.o.laststatus = vim.g.lualine_laststatus

  return {
    options = {
      theme = "auto",
      globalstatus = vim.o.laststatus == 3,
      disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        {

          "branch",
          fmt = function(str)
            if not str or str == "" then
              return str
            end
            local last_segment = str:match("([^/]+)$")
            return last_segment or str
          end,
        },
      },
      lualine_c = {
        LazyVim.lualine.root_dir(),
        {
          function()
            return SubMode.icon()
          end,
          color = function()
            return { fg = Snacks.util.color("Character") }
          end,
        },
        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        {
          function()
            return require("grapple").name_or_index()
          end,
          cond = function()
            return package.loaded["grapple"] and require("grapple").exists()
          end,
          color = function()
            return { fg = Snacks.util.color("Character") }
          end,
        },
        -- { LazyVim.lualine.pretty_path() },
        { "filename", path = 0 },
      },
      lualine_x = {
        {
          function()
            return "  " .. require("dap").status()
          end,
          cond = function()
            return package.loaded["dap"] and require("dap").status() ~= ""
          end,
          color = function()
            return { fg = Snacks.util.color("Debug") }
          end,
        },
      },
      lualine_y = {},
      lualine_z = {
        {
          "tabs",
          use_mode_colors = true,
          show_modified_status = false,
          mode = 1,
          tabs_color = {
            inactive = { bg = "#181825", fg = "#CDD6f4" },
          },
          fmt = function(name, context)
            if name and name == "[No Name]" or name and string.find(name, "%.") then
              return context.tabnr
            else
              return name
            end
          end,
        },
      },
    },
    extensions = { "neo-tree", "lazy" },
  }
end

---@type markview.config.markdown.list_items
M.markview_list_items_options = {
  enable = true,
  wrap = true,

  indent_size = function(buffer)
    if type(buffer) ~= "number" then
      return 0
      -- return vim.bo.shiftwidth or 2
    end

    --- Use 'shiftwidth' value.
    return 0
    -- return vim.bo[buffer].shiftwidth or 2
  end,
  shift_width = 2,

  marker_minus = {
    add_padding = true,
    conceal_on_checkboxes = true,

    text = "●",
    hl = "MarkviewListItemMinus",
  },

  marker_plus = {
    add_padding = true,
    conceal_on_checkboxes = true,

    text = "◈",
    hl = "MarkviewListItemPlus",
  },

  marker_star = {
    add_padding = true,
    conceal_on_checkboxes = true,

    text = "◇",
    hl = "MarkviewListItemStar",
  },

  marker_dot = {
    add_padding = true,
    conceal_on_checkboxes = true,
  },

  marker_parenthesis = {
    add_padding = true,
    conceal_on_checkboxes = true,
  },
}

return M
