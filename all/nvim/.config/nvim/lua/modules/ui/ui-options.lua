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
    bold = true,
    italic = true,
    transparency = true,
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
      lualine_b = { "branch" },
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
        { LazyVim.lualine.pretty_path() },
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
