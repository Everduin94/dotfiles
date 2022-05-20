local ls = require"luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")

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
          return '(' .. os.date("%x") .. ' - ' .. os.date("%I") .. ':' .. os.date("%M") .. string.lower(os.date("%p")) .. '):'
end

function today(args, snip, user_args1)
          return os.date("%x")
end

ls.add_snippets("all", {
    s("filename", { f(getFileName) }),
    -- File path completion, deletes line up to next `/` IDK how to fix
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
    s("sprintday", {
      f(getFileName),
      t({"", ""}),
      f(getMonthTag),
      t({"", "Created: "}),
      f(getFullDate),
      t({"", "Back: [["}), i(1, "path"), t({"]]"}),
      t({"", "-----------", ""}),
      t({"", "## Goals "}),
      t({"", "- "}), i(2),
      t({"", "## Sprints", ""}),
      t({"", "| Timeframe  | Type              | Previous | Gameplan                   | Adding | Retro |"}),
      t({"", "|------|--------------------|----------------|---------------|-------|-------|", ""}),
      t({"| 7:00-9:00   |"}), i(0),   t({" | | | | |", ""}),
      t({"| 9:00-11:00   | | | | | |", ""}),
      t({"| 11:00-1:00   | | | | | |", ""}),
      t({"| 1:00-3:00    | | | | | |", ""}),
      t({"| 3:00-5:00   | | | | | |", ""}),
      t({"| 5:00-7:00   | | | | | |", ""}),
      t({"| 7:00-9:00   | | | | | |", ""}),
      t({"| 9:00-11:00  | | | | | |", ""}),
      t({"", "### Tasks "}),
      t({"", "- "}), i(3),
      t({"", ""}),
    }),
    s("sprintweek", {
      f(getFileName),
      t({"", ""}),
      f(getMonthTag),
      t({"", "Created: "}),
      f(getFullDate),
      t({"", "Back: [["}), i(1, "path"), t({"]]"}),
      t({"", "-----------", ""}),
      t({"", "## Goals "}),
      t({"", "- "}), i(2),
      t({"", "## High Level View", ""}),
      t({"", "| Week | Building from previous | Doing today | Adding to next | Retro |"}),
      t({"", "|------|--------------------|----------------|---------------|-------|"}),
      t({"", "|" }), i(0), t({" | | | | |", ""}),
      t({"", "### Weekly Could Do "}),
      t({"", "- "}), i(3),
    }),
    s("sprintmonth", {
      f(getFileName),
      t({"", ""}),
      f(getMonthTag),
      t({"", "Created: "}),
      f(getFullDate),
      t({"", "Back: [["}), i(1, "path"), t({"]]"}),
      t({"", "-----------", ""}),
      t({"", "## Goals "}),
      t({"", "- "}), i(2),
      t({"", ""}),
      t({"", "| Week                       | Building from previous          | Doing this week | Adding to next                | Retro |"}),
      t({"", "|----------------------------|---------------------------------|-----------------|-------------------------------|-------|"}),
      t({"", "| [[./2022-month.week-1.md]] |                       |                |                              |       |"}),
      t({"", "| [[./2022-month.week-2.md]] |                       |                |                              |       |"}),
      t({"", "| [[./2022-month.week-3.md]] |                       |                |                              |       |"}),
      t({"", "| [[./2022-month.week-4.md]] |                       |                |                              |       |"}),
      i(0),
      t({"", ""}),
      t({"", "### Monthly Could Do "}),
      t({"", "- "}), i(3),
    }),
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
  })

ls.add_snippets("lua", {
    s("todo", { t("-- TODO "), f(timeStamp), t(" "), i(0) })
  })

ls.add_snippets("typescript", {
    s("todo", { t("// TODO "), f(timeStamp), t(" "), i(0) })
  })

ls.add_snippets("html", {
    s("todo", { t("<!-- TODO "), f(timeStamp), t(" "), i(0), t(" -->") }),
    s("if", { t('<ng-container *ngIf="'), i(1), t('"' .. '>'), i(0),  t('</ng-container>')}),
    s("ifelse", {
      t('<ng-container *ngIf="'),  i(1),  t('; else '), i(2), t('">'), i(0),  t('</ng-container>'),
      t({"", "<ng-template #"}),
      f(function(args, snip, user_arg_1, user_arg_2) return args[1][1] end, {2}),
      t(">"), i(3), t("</ng-template>")
    }),
    s("async", { t('<ng-container *ngIf="'), i(1),  t(' | async as '), i(2), t('">'), i(0), t('</ng-container>')}),
    s("for", { t('<ng-container *ngFor="let '), i(1), t(' of '), i(2), t('">'), i(0), t('</ng-container>')}),
  })
