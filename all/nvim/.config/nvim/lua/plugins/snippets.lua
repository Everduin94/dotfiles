return {
  {
    "L3MON4D3/LuaSnip",
    build = (not LazyVim.is_win())
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
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

      -- HACK: I can't get this to work, so try later in auto commands.
      local opts = { noremap = true }
      vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)

      -- HACK: Use rep(1) instead? This broke?
      local same = function(index)
        return f(function(args)
          return args[1]
        end, { index })
      end

      local sv = require("config/snippet-values")
      local function remove_leader(input)
        return input:gsub("^<leader>", "")
      end
      local tbl = {}
      for _, v in pairs(sv) do
        table.insert(tbl, ls.parser.parse_snippet({ trig = remove_leader(v.key) }, v.body))
      end
      ls.add_snippets("typescript", tbl, { key = "typescript" })
      ls.add_snippets("svelte", tbl, { key = "svelte" })

      -- ls.add_snippets("typescript", {
      --   -- ls.parser.parse_snippet({ trig = "lspsyn" }, "Wow! This ${1:Stuff} really ${2:works. ${3:Well, a bit.}}"),
      --   s("todo", { t("-- TODO: "), f(timeStamp), t(" "), i(0) }),
      -- }, { key = "typescript" })

      ls.add_snippets("lua", {
        s("todo", { t("-- TODO: "), f(timeStamp), t(" "), i(0) }),
        s("if", fmt("if {statement} then\n\t{fin}\nend", { statement = i(1), fin = i(0) })),
        s("log", fmt("print({statement})", { statement = i(1) })),
        s("inspect", fmt("print(vim.inspect({statement}))", { statement = i(1) })),
      }, { key = "lua" })
      -- ls.add_snippets("typescript", {
      --   s("todo", { t("// TODO: "), f(timeStamp), t(" "), i(0) }),
      --   s("if", fmt("if ({statement}) {{ \n\t{fin}\n}}", { statement = i(1), fin = i(0) })),
      --   s("log", fmt("console.log({statement})", { statement = i(1) })),
      --   s("random-item", fmt("{array}[Math.floor(Math.random() * {array}.length)]", { array = i(1) })),
      --   s(
      --     "deep-equals",
      --     fmt("const result = JSON.stringify({objOne}) === JSON.stringify({objTwo})", { objOne = i(1), objTwo = i(2) })
      --   ),
      --   ls.parser.parse_snippet({ trig = remove_leader("<leader>mf1") }, "$1 test"),
      --   ls.parser.parse_snippet({ trig = "mf2" }, "$1 test"),
      --   s(
      --     "catch",
      --     fmt("try {{ \n\t{statement}\n}} catch(error) {{ \n\tconsole.error(error); \n}}", { statement = i(1) })
      --   ),
      -- }, { key = "typescript" })

      ls.add_snippets("go", {
        s("todo", { t("// TODO: "), f(timeStamp), t(" "), i(0) }),
        s("if", fmt("if {statement} {{ \n\t{fin}\n}}", { statement = i(1), fin = i(0) })),
        s("log", fmt("fmt.Println({statement})", { statement = i(1) })),
        s(
          "random-item",
          fmt("rand.Seed(time.Now().UnixNano())\n result := {array}[rand.Intn(len({array}))]", { array = i(1) })
        ),
        s("deep-equals", fmt("result := reflect.DeepEqual({objOne}, {objTwo})", { objOne = i(1), objTwo = i(2) })),
        s(
          "catch",
          fmt(
            'if {condition} {{ \n\t return {value}, errors.New("{error}")\n}}',
            { condition = i(1), value = i(2), error = i(3) }
          )
        ),
      }, { key = "go" })
    end,
    -- TODO: If cmp didn't auto select. Tab could be a good way to "select" without code-action.
    -- CTRL-Enter feels okay when typing. But, when writing code with brackets it feels pretty invasive
    -- Today: enter to just enter. ctrl+f to select, tab to walk, ctrl+e to exit, tab to move to next snippet (should add ctrl+d back).
    -- if for catch
    -- random-item deep-equals
  },
}
