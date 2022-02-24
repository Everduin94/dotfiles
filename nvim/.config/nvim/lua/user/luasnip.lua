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

ls.snippets = {
  all = {
    s("trigger", {
      f(function(args, snip)
        local value = snip.env.TM_FILENAME_BASE
        local result = ""
        local separator = "# ";
        for word in value:gmatch("%w+") do
          result = result .. separator .. word:gsub("^%l", string.upper)
          separator = " "
        end
        return result
      end, {})
    })
  }
}
