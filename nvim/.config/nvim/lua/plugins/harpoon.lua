local function term(list_item, list, options)
  local Extensions = require("harpoon.extensions")
  local Logger = require("harpoon.logger")

  Logger:log("term_config#select", list_item, list.name, options)

  options = options or {}

  -- Terminal
  if list_item == nil then
    vim.cmd("terminal")
    require("harpoon"):list("term"):add()
    return
  end

  local bufnr = vim.fn.bufnr(list_item.value)
  local set_position = false

  if bufnr == -1 then
    set_position = true
    bufnr = vim.fn.bufnr(list_item.value, true)
  end

  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
    vim.api.nvim_set_option_value("buflisted", true, {
      buf = bufnr,
    })
  end

  if options.vsplit then
    vim.cmd("vsplit")
  elseif options.split then
    vim.cmd("split")
  elseif options.tabedit then
    vim.cmd("tabedit")
  end

  vim.api.nvim_set_current_buf(bufnr)

  if set_position then
    vim.api.nvim_win_set_cursor(0, {
      list_item.context.row or 1,
      list_item.context.col or 0,
    })
  end

  Extensions.extensions:emit(Extensions.event_names.NAVIGATE, {
    buffer = bufnr,
  })
end

return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },

      default = {
        select_with_nil = true,
        encode = false,
      },
      term = {
        select_with_nil = true,
        encode = false,
        select = term,
      },
    },
    keys = function()
      local keys = {
        {
          "<leader>H",
          function()
            require("harpoon"):list():add()
          end,
          desc = "Harpoon File",
        },
        {
          "<leader>h",
          function()
            local harpoon = require("harpoon")
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = "Harpoon Quick Menu",
        },
      }

      for i = 1, 5 do
        table.insert(keys, {
          "<leader>" .. i,
          function()
            require("harpoon"):list():select(i)
          end,
          desc = "Harpoon to File " .. i,
        })
      end
      return keys
    end,
  },
  {
    "Everduin94/nvim-quick-switcher",
    init = function()
      vim.api.nvim_create_autocmd({ "SessionLoadPost", "UIEnter" }, {
        callback = function(event)
          local map = LazyVim.safe_keymap_set
          local function find(file_regex, opts)
            return function()
              require("nvim-quick-switcher").find(file_regex, opts)
            end
          end

          local function inline_ts_switch(file_type, scheme)
            return function()
              require("nvim-quick-switcher").inline_ts_switch(file_type, scheme)
            end
          end
          local is_angular = next(vim.fs.find({ "angular.json", "nx.json" }, { upward = true }))
          local is_svelte = next(vim.fs.find({ "svelte.config.js", "svelte.config.ts" }, { upward = true }))

          print(is_svelte, is_angular)

          -- Styles
          map(
            "n",
            "<leader>oi",
            find(".+css|.+scss|.+sass", { regex = true, prefix = "full", drop = true }),
            { desc = "Go to Styles" }
          )

          -- Types
          map(
            "n",
            "<leader>orm",
            find(".+model.ts|.+models.ts|.+types.ts", { regex = true }),
            { desc = "Go to Models" }
          )

          -- Util
          map("n", "<leader>ol", find("*util.*", { prefix = "short" }), { desc = "Go to Util" })

          -- Tests
          map("n", "<leader>ot", find(".+test|.+spec", { regex = true, prefix = "full" }), { desc = "Go to Test" })

          -- Angular
          if is_angular then
            print("Angular")
            map("n", "<leader>oo", find(".component.html"), { desc = "Go to HTML" })
            map("n", "<leader>ou", find(".component.ts"), { desc = "Go to Typescript" })
            map("n", "<leader>op", find(".module.ts"), { desc = "Go to Module" })
            map("n", "<leader>oy", find(".service.ts"), { desc = "Go to Service" })
          end

          -- SvelteKit
          if is_svelte then
            print("Svelte")
            vim.keymap.set(
              "n",
              "<leader>oo",
              find("*page.svelte", { maxdepth = 1, ignore_prefix = true }),
              { desc = "Go to Svelte" }
            )
            vim.keymap.set(
              "n",
              "<leader>ou",
              find(".*page.server(.+js|.+ts)|.*page(.+js|.+ts)", { maxdepth = 1, regex = true, ignore_prefix = true }),
              { desc = "Go to Server" }
            )
            vim.keymap.set(
              "n",
              "<leader>op",
              find("*layout.svelte", { maxdepth = 1, ignore_prefix = true }),
              { desc = "Go to Layout" }
            )

            -- Inline TS
            vim.keymap.set(
              "n",
              "<leader>ok",
              inline_ts_switch("svelte", "(script_element (end_tag) @capture)"),
              { desc = "Go to Script" }
            )
            vim.keymap.set(
              "n",
              "<leader>oj",
              inline_ts_switch("svelte", "(style_element (start_tag) @capture)"),
              { desc = "Go to Style" }
            )
          end
        end,
      })
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  },
}
