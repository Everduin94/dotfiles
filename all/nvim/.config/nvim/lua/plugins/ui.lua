return {
  -- Incline
  {
    "b0o/incline.nvim",
    config = function()
      require("incline").setup({
        render = function(props)
          local fname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          local colors = require("catppuccin.palettes").get_palette("mocha")

          if ZEN_MODE == true then
            return
          end

          if props.focused == true then
            return {
              {
                " " .. fname .. " ",
                guibg = colors.base,
                guifg = colors.text,
              },
            }
          else
            return {
              {
                " " .. fname .. " ",
                guibg = colors.base,
                guifg = colors.overlay0,
              },
            }
          end
        end,
      })
    end,
    event = "VeryLazy",
  },
  -- Lualine
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = " "
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      local lualine_require = require("lualine_require")
      lualine_require.require = require

      local icons = require("lazyvim.config").icons

      -- NOTE: Refactor and move
      local map = LazyVim.safe_keymap_set
      local sub_mode = "Buffer"

      -- Sub mode

      -- Git
      map("n", "<leader>gk", function()
        require("gitsigns").next_hunk()
        map("n", "<TAB>", "<cmd>lua require([[gitsigns]]).next_hunk() <CR>")
        map("n", "<S-TAB>", "<cmd>lua require([[gitsigns]]).prev_hunk() <CR>")
        sub_mode = "Git"
      end, { desc = "Git Hunk Mode" })

      -- Diagnostic
      map("n", "<leader>gn", function()
        vim.diagnostic.goto_next()
        map("n", "<TAB>", "<cmd>lua vim.diagnostic.goto_next() <CR>")
        map("n", "<S-TAB>", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
        sub_mode = "Diagnostic"
      end, { desc = "Diagnostic Mode" })

      -- Quick Fix
      map("n", "<leader>gx", function()
        vim.api.nvim_command("copen")
        map("n", "<TAB>", "<cmd>cn<CR>zz")
        map("n", "<S-TAB>", "<cmd>cp<CR>zz")
        sub_mode = "Quick Fix"
      end, { desc = "Quick Fix Mode" })

      -- Clear
      map("n", "<leader>g/", function()
        map("n", "<TAB>", "<cmd>bnext<CR>")
        map("n", "<S-TAB>", "<cmd>bprevious<CR>")
        sub_mode = "Buffer"
      end, { desc = "Buffer Mode" })

      -- Spellcheck
      map("n", "<leader>gp", function()
        -- <leader>us to enable
        vim.api.nvim_feedkeys("]s", "n", false)
        map("n", "<TAB>", "]s")
        map("n", "<S-TAB>", "[s")
        sub_mode = "Spellcheck"
      end, { desc = "Spellcheck Mode" })

      local function get_mode_icon()
        if sub_mode == "Buffer" then
          return "󰀘"
        end
        if sub_mode == "Quick Fix" then
          return ""
        end
        if sub_mode == "Git" then
          return "󰊢"
        end
        if sub_mode == "Diagnostic" then
          return "󱩔"
        end
        if sub_mode == "Spellcheck" then
          return "󰓆"
        end
      end

      -- HACK: The LazyVim get colors fails on Visual-Block
      local mocha = require("catppuccin.palettes").get_palette("mocha")
      local colors = {
        bg = "#202328",
        fg = "#bbc2cf",
        yellow = mocha.yellow,
        cyan = mocha.sky,
        darkblue = "#081633",
        green = mocha.green,
        orange = mocha.peach,
        violet = mocha.lavender,
        magenta = mocha.mauve,
        blue = mocha.blue,
        red = mocha.red,
      }
      local function getModeColor(fg)
        -- auto change color according to neovims mode
        local mode_color = {
          n = colors.blue,
          i = colors.green,
          v = colors.magenta,
          [""] = colors.magenta,
          V = colors.magenta,
          c = colors.yellow,
          no = colors.red,
          s = colors.orange,
          S = colors.orange,
          [""] = colors.orange,
          ic = colors.yellow,
          R = colors.violet,
          Rv = colors.violet,
          cv = colors.red,
          ce = colors.red,
          r = colors.cyan,
          rm = colors.cyan,
          ["r?"] = colors.cyan,
          ["!"] = colors.red,
          t = colors.orange,
        }
        if fg then
          return { bg = mode_color[vim.fn.mode()], fg = "#11111b", gui = "bold" }
        end

        return { fg = mode_color[vim.fn.mode()], bg = mocha.surface0, gui = "bold" }
      end

      vim.o.laststatus = vim.g.lualine_laststatus

      local opts = {
        options = {
          theme = "auto",
          globalstatus = vim.o.laststatus == 3,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
        },
        sections = {
          lualine_a = {
            "mode",
          },
          lualine_b = { "branch" },

          lualine_c = {
            LazyVim.lualine.root_dir(),
            {
              function()
                return get_mode_icon()
              end,
              color = function()
                return { fg = Snacks.util.color("Character") }
                -- return LazyVim.ui.fg("Character")
              end,
            },
            -- {
            --   "diagnostics",
            --   symbols = {
            --     error = icons.diagnostics.Error,
            --     warn = icons.diagnostics.Warn,
            --     info = icons.diagnostics.Info,
            --     hint = icons.diagnostics.Hint,
            --   },
            -- },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { LazyVim.lualine.pretty_path() },
            -- { "filename" },
          },
          lualine_x = {
          -- stylua: ignore
          -- {
          --   function() return require("noice").api.status.command.get() end,
          --   cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
          --   color = function() return LazyVim.ui.fg("Statement") end,
          -- },
          -- stylua: ignore
          -- {
          --   function() return require("noice").api.status.mode.get() end,
          --   cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
          --   color = function() return LazyVim.ui.fg("Constant") end,
          -- },
          -- stylua: ignore
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = function() return { fg = Snacks.util.color("Debug") } end
            -- color = function() return LazyVim.ui.fg("Debug") end,
          },
            -- stylua: ignore
            -- {
            --   require("lazy.status").updates,
            --   cond = require("lazy.status").has_updates,
            --   color = function() return LazyVim.ui.fg("Special") end,
            -- },
            -- {
            --   "diff",
            --   symbols = {
            --     added = icons.git.added,
            --     modified = icons.git.modified,
            --     removed = icons.git.removed,
            --   },
            --   source = function()
            --     local gitsigns = vim.b.gitsigns_status_dict
            --     if gitsigns then
            --       return {
            --         added = gitsigns.added,
            --         modified = gitsigns.changed,
            --         removed = gitsigns.removed,
            --       }
            --     end
            --   end,
            -- },
          },
          lualine_y = {
            -- { "progress", separator = " ", padding = { left = 1, right = 0 } },
            -- { "location", padding = { left = 0, right = 1 } },
          },

          lualine_z = {
            {
              "tabs",
              -- separator = { right = "", left = "" }, --
              use_mode_colors = true,
              show_modified_status = false,
              mode = 1,
              tabs_color = {
                -- active = function()
                --   return LazyVim.ui.fg(vim.fn.mode())
                -- end,
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

      -- do not add trouble symbols if aerial is enabled
      -- if vim.g.trouble_lualine then
      --   local trouble = require("trouble")
      --   local symbols = trouble.statusline
      --     and trouble.statusline({
      --       mode = "symbols",
      --       groups = {},
      --       title = false,
      --       filter = { range = true },
      --       format = "{kind_icon}{symbol.name:Normal}",
      --       hl_group = "lualine_c_normal",
      --     })
      --   table.insert(opts.sections.lualine_c, {
      --     symbols and symbols.get,
      --     cond = symbols and symbols.has,
      --   })
      -- end

      return opts
    end,
  },
  -- {
  --   "folke/which-key.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     plugins = {
  --       spelling = true,
  --       marks = false,
  --       registers = false,
  --       presets = {
  --         operators = false, -- adds help for operators like d, y, ...
  --         motions = false, -- adds help for motions
  --         text_objects = false, -- help for text objects triggered after entering an operator
  --         windows = false, -- default bindings on <c-w>
  --         nav = false, -- misc bindings to work with windows
  --         z = false, -- bindings for folds, spelling and others prefixed with z
  --         g = false, -- bindings for prefixed with g
  --       },
  --     },
  --     defaults = {
  --       mode = { "n", "v" },
  --       ["g"] = { name = "+goto" },
  --       ["gs"] = { name = "+surround" },
  --       ["z"] = { name = "+fold" },
  --       ["]"] = { name = "+next" },
  --       ["["] = { name = "+prev" },
  --       ["<leader><tab>"] = { name = "+tabs" },
  --       ["<leader>b"] = { name = "+buffer" },
  --       ["<leader>c"] = { name = "+code" },
  --       ["<leader>f"] = { name = "+file/find" },
  --       ["<leader>g"] = { name = "+git" },
  --       ["<leader>gh"] = { name = "+hunks" },
  --       ["<leader>q"] = { name = "+quit/session" },
  --       ["<leader>s"] = { name = "+search" },
  --       ["<leader>u"] = { name = "+ui" },
  --       ["<leader>w"] = { name = "+windows" },
  --       ["<leader>x"] = { name = "+diagnostics/quickfix" },
  --     },
  --   },
  --   config = function(_, opts)
  --     local wk = require("which-key")
  --     wk.setup(opts)
  --     wk.add(opts.defaults)
  --   end,
  -- },
}
