require("catppuccin").setup({
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    -- How can we dynamically turn this off?
    transparent_background = true,
    term_colors = false,
    dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        loops = { "italic" },
        functions = { "italic" },
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
          Boolean = {fg = colors.sapphire},
      ["@parameter"] = { fg = colors.teal },
      ["@constant"] = { fg = colors.sapphire },
      ["@constant.builtin"] = { fg = colors.sapphire },
      ["@function.builtin"] = { fg = colors.sapphire },
      ["@variable.builtin"] = { fg = colors.pink },
      ["@method.call"] = { fg = colors.pink },
      ["@number.css"] = { fg = colors.sapphire },
      ["@text.strong"] = { fg = colors.pink },
      ["@type.builtin"] = { fg = colors.teal },
      ["Type"] = { fg = colors.teal },
      
        }
    end,
  integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        notify = false,
        mini = false,
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
})

-- setup must be called before loading
vim.cmd.colorscheme "catppuccin"


