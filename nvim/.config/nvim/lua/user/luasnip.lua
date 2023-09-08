local ls = require"luasnip"
local sql = require'user.snippets.sql'
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local types = require "luasnip.util.types"
local events = require("luasnip.util.events")
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta -- Uses angle brackets
vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/lua/user/luasnip.lua<CR>")
vim.keymap.set("i", "<c-u>", require "luasnip.extras.select_choice")
ls.config.set_config {
  history = true,
  updateevents = "TextChanged,TextChangedI",
  enable_autosnippets = true,
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { "", "DiagnosticHint" } },
      },
    },
    [types.insertNode] = {
      active = {
        virt_text = { { "", "DiagnosticHint" } },
      },
    },
  },
}


-- Utils
local newline = function(text)
  return t { "", text }
end

  -- Currying example
local same = function(index)
  return f(function(args)
    return args[1]
  end, { index })
end

local function isempty(s)
  return s == nil or s == ''
end

-- Mock Examples
-- Inner snippet + dynamic node example
local get_test_result = function(position)
  return d(position, function()
    local nodes = {}
    table.insert(nodes, t " ")
    table.insert(nodes, t " -> Result<(), MyError> ")

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for _, line in ipairs(lines) do
      if line:match "anyhow::Result" then
        table.insert(nodes, t " -> Result<()> ")
        break
      end
    end

    return sn(nil, c(1, nodes))
  end, {})
end


-- Legacy Functions
function getFileName(args, snip, user_args1)
        local value = snip.env.TM_FILENAME_BASE
        local result = ""
        local separator = "# ";
        for word in value:gmatch("%w+") do
          result = result .. separator .. word:gsub("^%l", string.upper)
          separator = " "
        end
        return result
end

function getFullDate(args, snip, user_args1)
          local month = snip.env.CURRENT_MONTH
          local day = snip.env.CURRENT_DATE
          local year = snip.env.CURRENT_YEAR
          return month .. '/' .. day .. '/' .. year
end

function getMonthTag(args, snip, user_args1)
          local month = snip.env.CURRENT_MONTH_NAME
          local year = snip.env.CURRENT_YEAR
          return '#' .. year .. '-' .. string.lower(month)
end

-- TODO (03/14/2022 - 10:27am): This gets passed in like getMonthTag to f(). Figure out a way to not use #
function getMonth(args, snip, user_args1)
          local month = snip.env.CURRENT_MONTH_NAME
          local year = snip.env.CURRENT_YEAR
          return year .. '-' .. string.lower(month)
end

function timeStamp(args, snip, user_args1)
          return os.date "(%x - %I:%M%p): "
end

function today(args, snip, user_args1)
          return os.date("%x")
end




local rxjsOperators = function(args)
    if next(args) == nil or vim.fn.trim(args[1][2]) ~= '' and args[1][2] ~= nil then
      return sn(nil,  {newline(""), c(1, {t(nil), 
        sn(nil, t("distinctUntilChanged(),")), 
        sn(nil, fmt("debounceTime({}),", {i(1)})), 
        sn(nil, fmt("withLatestFrom({}),", {i(1)})), 
        sn(nil, fmt("filter(({}) => {{ return {} }})," , {i(1), i(2)})), 
        sn(nil, fmt("map(({}) => {{ return {} }})," , {i(1), i(2)})), 
        sn(nil, fmt("map(([{}]) => ({{ {} }}))," , {i(1), same(1)})), 
        sn(nil, fmt("tap(({}) => {{ {} }})," , {i(1), i(2)})), 
        sn(nil, fmt("tap(({}) => {{  console.log({}) }})," , {i(1), same(1)})), 
        sn(nil, fmt("switchMap(({}) => {{ return {} }}),", {i(1), i(2)})), 
        sn(nil, fmt("scan((acc, curr) => {{ return {{...acc, curr}}  }}, {}),", {i(1, "defaultValue")})), 
        sn(nil, t("shareReplay({ refCount: true, bufferSize: 1, }),")),
      })})
    end
  return sn(nil, t(nil))
end

-- Breaks arrayFns w/o newline. Must be related to [1][2]
local arrayStarter = function(args)
  return sn(nil,  {newline(""), c(1, {t(nil), 
    sn(nil, fmt("Object.values({}){}" , {i(1), i(0)})), 
    sn(nil, fmt("Array.from({}){}" , {i(1), i(0)})), 
  })})
end

local arrayFns = function(args)
    if next(args) == nil or vim.fn.trim(args[1][2]) ~= '' and args[1][2] ~= nil then
      return sn(nil,  {newline(""), c(1, {t(nil), 
        sn(nil, fmt(".filter(({}) => {{ return {} }})" , {i(1), i(2)})), 
        sn(nil, fmt(".map(({}) => {{ return {} }})" , {i(1), i(2)})), 
        sn(nil, fmt(".forEach(({}) => {{ {} }})" , {i(1), i(2)})), 
        sn(nil, fmt(".forEach(({}) => {{  console.log({}) }})" , {i(1), same(1)})), 
        sn(nil, fmt(".reduce((acc, curr) => {{ return {{...acc, curr}}  }}, {})", {i(1, "defaultValue")})), 
      })})
    end
  return sn(nil, t(nil))
end


-- intersection obs
local temp = 'const the_animation = document.querySelectorAll(".animation");{fin} const observer = new IntersectionObserver( (entries) => {{ entries.forEach((entry) => {{ if (entry.isIntersecting) {{ entry.target.classList.add("scroll-animation"); observer.unobserve(entry.target) }}  }}); }}, {{ threshold: 0.12 }}); for (let i = 0; i < the_animation.length; i++) {{ const elements = the_animation[i]; observer.observe(elements); }}'

ls.add_snippets("all", {
    s("filename", { f(getFileName) }),
    s("sql_table_schema", fmt(sql.sql_table .. '{fin}', { fin = i(0)}) ),
    s("sql_query_join", fmt(sql.sql_query_join .. '{fin}', { fin = i(0)}) ),
    s("sql_query_array_lateral", fmt(sql.sql_query_array_lateral .. '{fin}', { fin = i(0)}) ),
    s("sql_query_array_agg", fmt(sql.sql_query_array_agg .. '{fin}', { fin = i(0)}) ),
    s("sql_function", fmt(sql.sql_function .. '{fin}', { fin = i(0)}) ),
    s("indexn", {
      f(getFileName),
      t({"", ""}),
      f(getMonthTag),
      t({"", "Created: "}),
      f(getFullDate),
      t({"", "Back: [["}), i(1, "path"), t({"]]"}),
      t({"", "-----------", ""}), i(0)
    }),
    s("timestamp", { f(timeStamp) }),
    s("today", { f(today) }),
    
    s("cornell", {
      f(getFileName),
      t({"", ""}),
      f(getMonthTag),
      t({"", "Created: "}), f(getFullDate),
      t({"", "Back: [["}), i(1, "path"), t({"]]"}),
      t({"", "-----------", ""}),
      t({"", "| Question | Answer |"}),
      t({"", "|----------|--------|"}),
      t({"", "|" }), i(0), t({" | |", ""}),
      t({"", "### 🧪 Summary"}),
      t({"", "```", ""}),
      t({"", "```", ""}),
    }),
    s("info", fmt('<details class="info" open>\n<summary>{X}</summary>\n\n{fin}\n\n</details>', {X = i(1), fin = i(0)})),
    s({trig="info-cornell", dscr="This is my description, does this work?"}, fmt('<details class="cornell" open>\n<summary>{X}</summary>\n\n| key | description |\n| --- | ---------- |\n|{fin}   |      |\n\n Summary\n\n```\n```\n\n</details>', {X = i(1), fin = i(0)})),
  }, { key = 'all'})

ls.add_snippets("lua", {
    s("todo", { t("-- TODO "), f(timeStamp), t(" "), i(0) }),
    s("if", fmt("if {statement} then\n\t{fin}\nend", {statement = i(1), fin = i(0)})),
    s("log", fmt("print({statement})", {statement = i(1)})),
    s("inspect", fmt("print(vim.inspect({statement}))", {statement = i(1)})),
  } , { key = 'lua' })

ls.add_snippets("scss", {
    s("log", fmt("* {{ \n\toutline: 3px solid limegreen !important;\n\tbackground: rgb(0 100 0 / 0.1) !important;\n}}", {})),
    s("classr", fmt(".{statement} {{\n\t{fin}\n}}", {statement = f(function() return vim.fn.getreg('"') end), fin = i(0)})),
    s("class", fmt(".{statement} {{\n\t{fin}\n}}", {statement = i(1), fin = i(0)})),
  }, { key = 'scss' })





  -- Possible future snippets
  -- this.store.update(...choice)
  -- this.store.pipe(...choice [elf select functions])
  -- More clipboard snippets
ls.add_snippets("typescript", {
    s(
      "pipe",
      {
      t("pipe("),
      d(1, rxjsOperators, nil),
      d(2, rxjsOperators, { 1 }),
      d(3, rxjsOperators, { 2 }),
      d(4, rxjsOperators, { 3 }),
      d(5, rxjsOperators, { 4 }),
      d(6, rxjsOperators, { 5 }),
      newline(""),
      t(");")
      }
    ),
    s("pipe-in",
    {
      d(1, rxjsOperators, nil),
      d(2, rxjsOperators, { 1 }),
      d(3, rxjsOperators, { 2 }),
      d(4, rxjsOperators, { 3 }),
      d(5, rxjsOperators, { 4 }),
      d(6, rxjsOperators, { 5 }),
      newline(""),
    }
    ),
    s("arr.",
    {
      d(1, arrayStarter, i(1)),
      d(2, arrayFns, { 1 }),
      d(3, arrayFns, { 2 }),
      d(4, arrayFns, { 3 }),
      d(5, arrayFns, { 4 }),
      d(6, arrayFns, { 5 }),
      newline(""),
    }
    ),
    s("glue", fmt("const {statement}Glue = createGlue({{\n\t{fin}\n}}) ", {statement = i(1), fin = i(0)})),
    s("if", fmt("if({statement}) {{\n\t{fin}\n}}", {statement = i(1), fin = i(0)})),
    s("log", fmt("console.log(`{statement}`)", {statement = i(1)})),
    s("logr", fmt("console.log('{statement} :', {statement})", {statement = f(function() return vim.fn.getreg('"') end)})),
    s("todo", { t("// TODO "), f(timeStamp), t(" "), i(0) }),
    s("effectFn", {
      i(1), t("Effect = createEffectFn(("), i(2), t(": Observable<"), i(3), t(">"), t({") => { "}),
      t({"return "}), same(2), t({".pipe("}), i(0),
      t({")"}),
      t("});")
    }),
    s("effect", { i(1), t("$ = createEffect(actions => actions.pipe( ofType("), same(1), t("),") , i(0), t("));") }),
    s("action", { t("export const "), i(1), t(" = "), i(2), t(".create('"), i(3), t("')") }),
    s("actionInit", { t("export const "), i(1), t("Actions = "), t("actionsFactory('"), same(1), t("')") })
  }, { key = 'typescript' })

ls.add_snippets("svelte", {
  s("configurable_state", fmt('export let {X}: any;{fin}', {X = i(1), fin = i(0)})),
  s("two_way_state", fmt('type {X} = {{}} \nconst {Y} = {fin}writable<{X}>();', {X = i(1), Y = i(2), fin = i(0)}, {repeat_duplicates = true})),
  s("derive_state", fmt('$: {X} = update_{X}({Y})\n function update_{X}({Y}) {{ \n\n{fin} }}   ', {X = i(1), Y = i(2), fin = i(0)}, {repeat_duplicates = true})),
  s("derive_class", fmt('$: {X} = class_{X}({Y})\n function class_{X}({Y}) {{ \n\n{fin} }}\n\n class={{`${X}`}}',{X = i(1), Y = i(2), fin = i(0)}, {repeat_duplicates = true})),
  s("destructure_data", fmt('export let data;\n\n $: ({{ {fin} }} = data);', {fin = i(0)})),
  s("event_click", fmt('function event_{X} ({Y}) {{ \n\n {fin} }}\n\n on:click={{() => event_{X}({Y}) }}', {X = i(1), Y = i(2), fin = i(0)}, {repeat_duplicates = true})),
  s("starter", fmt('<script lang="ts">{fin}</script>\n\n<div class="grid">Hello {X}</div>\n\n<style></style>', {X = f(getFileName), fin = i(0)}, {repeat_duplicates = true})),
  s("intersectionobs", fmt(temp, {fin = i(0)}, {repeat_duplicates = true})),
})




-- 
	

ls.add_snippets("html", {
    s("glue-b", fmt('<glue-button [glue]="{statement}" {fin}></glue-button>', {statement = i(1), fin = i(0)})),
    s("log", fmt('<div class="log-me">{{{{ {statement} | json }}}}</div>', {statement = i(1)})),
    s("todo", { t("<!-- TODO "), f(timeStamp), t(" "), i(0), t(" -->") }),
    s("if", { t('<ng-container *ngIf="'), i(1), t('"' .. '>'), i(0),  t('</ng-container>')}),
    s("ifelse", {
      t('<ng-container *ngIf="'),  i(1),  t('; else '), i(2), t('">'), i(0),  t('</ng-container>'),
      t({"", "<ng-template #"}),
      same(2),
      t(">"), i(3), t("</ng-template>")
    }),
    s("async", { t('<ng-container *ngIf="'), i(1),  t(' | async as '), i(2), t('">'), i(0), t('</ng-container>')}),
    s("for", { t('<ng-container *ngFor="let '), i(1), t(' of '), i(2), t('">'), i(0), t('</ng-container>')}),
  })






-- TODO: Graveyard

-- s("sprintday", {
--       f(getFileName),
--       t({"", ""}),
--       f(getMonthTag),
--       t({"", "Created: "}),
--       f(getFullDate),
--       t({"", "Back: [["}), i(1, "path"), t({"]]"}),
--       t({"", "-----------", ""}),
--       t({"", "## Goals "}),
--       t({"", "- "}), i(2),
--       t({"", "## Sprints", ""}),
--       t({"", "| Timeframe  | Type              | Previous | Gameplan                   | Adding | Retro |"}),
--       t({"", "|------|--------------------|----------------|---------------|-------|-------|", ""}),
--       t({"| 7:00-9:00   |"}), i(0),   t({" | | | | |", ""}),
--       t({"| 9:00-11:00   | | | | | |", ""}),
--       t({"| 11:00-1:00   | | | | | |", ""}),
--       t({"| 1:00-3:00    | | | | | |", ""}),
--       t({"| 3:00-5:00   | | | | | |", ""}),
--       t({"| 5:00-7:00   | | | | | |", ""}),
--       t({"| 7:00-9:00   | | | | | |", ""}),
--       t({"| 9:00-11:00  | | | | | |", ""}),
--       t({"", "### Tasks "}),
--       t({"", "- "}), i(3),
--       t({"", ""}),
--     }),
--     s("sprintweek", {
--       f(getFileName),
--       t({"", ""}),
--       f(getMonthTag),
--       t({"", "Created: "}),
--       f(getFullDate),
--       t({"", "Back: [["}), i(1, "path"), t({"]]"}),
--       t({"", "-----------", ""}),
--       t({"", "## Goals "}),
--       t({"", "- "}), i(2),
--       t({"", "## High Level View", ""}),
--       t({"", "| Week | Building from previous | Doing today | Adding to next | Retro |"}),
--       t({"", "|------|--------------------|----------------|---------------|-------|"}),
--       t({"", "|" }), i(0), t({" | | | | |", ""}),
--       t({"", "### Weekly Could Do "}),
--       t({"", "- "}), i(3),
--     }),
--     s("sprintmonth", {
--       f(getFileName),
--       t({"", ""}),
--       f(getMonthTag),
--       t({"", "Created: "}),
--       f(getFullDate),
--       t({"", "Back: [["}), i(1, "path"), t({"]]"}),
--       t({"", "-----------", ""}),
--       t({"", "## Goals "}),
--       t({"", "- "}), i(2),
--       t({"", ""}),
--       t({"", "| Week                       | Building from previous          | Doing this week | Adding to next                | Retro |"}),
--       t({"", "|----------------------------|---------------------------------|-----------------|-------------------------------|-------|"}),
--       t({"", "| [[./2022-month.week-1.md]] |                       |                |                              |       |"}),
--       t({"", "| [[./2022-month.week-2.md]] |                       |                |                              |       |"}),
--       t({"", "| [[./2022-month.week-3.md]] |                       |                |                              |       |"}),
--       t({"", "| [[./2022-month.week-4.md]] |                       |                |                              |       |"}),
--       i(0),
--       t({"", ""}),
--       t({"", "### Monthly Could Do "}),
--       t({"", "- "}), i(3),
--     }),
