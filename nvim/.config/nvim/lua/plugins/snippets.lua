return {
  {
    "L3MON4D3/LuaSnip",
    build = (not LazyVim.is_win())
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      {
        "nvim-cmp",
        dependencies = {
          "saadparwaiz1/cmp_luasnip",
        },
        opts = function(_, opts)
          opts.snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body)
            end,
          }
          table.insert(opts.sources, { name = "luasnip" })
        end,
      },
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    init = function()
      local ls = require("luasnip")
      -- local sql = require'user.snippets.sql'
      local s = ls.snippet
      local sn = ls.snippet_node
      local isn = ls.indent_snippet_node
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node
      local c = ls.choice_node
      local d = ls.dynamic_node
      local r = ls.restore_node
      local types = require("luasnip.util.types")
      local events = require("luasnip.util.events")
      local fmt = require("luasnip.extras.fmt").fmt
      local fmta = require("luasnip.extras.fmt").fmta -- Uses angle brackets

      local function timeStamp(args, snip, user_args1)
        return os.date("(%x - %I:%M%p) ")
      end

      ls.add_snippets("lua", {
        s("todo", { t("-- TODO: "), f(timeStamp), t(" "), i(0) }),
        s("if", fmt("if {statement} then\n\t{fin}\nend", { statement = i(1), fin = i(0) })),
        s("log", fmt("print({statement})", { statement = i(1) })),
        s("inspect", fmt("print(vim.inspect({statement}))", { statement = i(1) })),
      }, { key = "lua" })
    end,
  },
}
