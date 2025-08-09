return {
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      transparent_background = true,
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
          Number = { fg = colors.red },
          Constant = { fg = colors.sapphire },
          Boolean = { fg = colors.red },
          ["@parameter"] = { fg = colors.teal },
          ["@keyword"] = { fg = colors.pink },
          ["@keyword.import"] = { fg = colors.pink },
          ["@keyword.function"] = { fg = colors.pink },
          ["@punctuation.delimiter"] = { fg = colors.pink },
          ["@property"] = { fg = colors.text },
          ["@variable.parameter"] = { fg = colors.text },
          ["@variable"] = { fg = colors.yellow },
          ["@variable.member"] = { fg = colors.text },
          ["@constant"] = { fg = colors.sapphire },
          ["@string"] = { fg = colors.teal },
          ["@constant.builtin"] = { fg = colors.sapphire },
          ["@function.builtin"] = { fg = colors.sapphire },
          ["@function"] = { fg = colors.sapphire },
          ["@function.method.call"] = { fg = colors.sapphire },
          ["@variable.builtin"] = { fg = colors.pink },
          ["@method.call"] = { fg = colors.pink },
          ["@number.css"] = { fg = colors.sapphire },
          ["@text.strong"] = { fg = colors.pink },
          ["@type.builtin"] = { fg = colors.teal },
          ["Type"] = { fg = colors.text },
          ["@type"] = { fg = colors.text },
          ["@module"] = { fg = colors.text },
        }
      end,
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      indent = { enable = true },
      ensure_installed = {
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
      },
    },
  },
  -- lua/plugins/rose-pine.lua
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
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
          bold = true,
          italic = true,
          transparency = true,
        },
      })
      vim.cmd("colorscheme rose-pine-moon")
    end,
  },
  {
    "nvim-treesitter/playground",
  },
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        svelte = {},
      },
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        lsp_doc_border = true,
      },
    },
  },
}
