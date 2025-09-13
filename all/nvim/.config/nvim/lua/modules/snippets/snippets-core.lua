local M = {}

local gn = require("config/generators/generator")

local function map_snippet_which_key(tbl, func)
  local new_tbl = {}
  for _, v in pairs(tbl) do
    table.insert(new_tbl, func(v))
  end
  return new_tbl
end

-- Define the transformation function
local function snippet_to_which_key(snippet)
  return {
    snippet.key,
    function()
      nexpand(snippet.body)
    end,
    desc = snippet.desc,
    icon = snippet.icon,
  }
end

local function generator_to_which_key(generator)
  return {
    generator.key,
    generator.fn,
    desc = generator.desc,
    icon = generator.icon,
  }
end

local function which_key_generators()
  return map_snippet_which_key(gn, generator_to_which_key)
end

local function which_key_snippets(tbl)
  return map_snippet_which_key(tbl, snippet_to_which_key)
end

M.luasnip = {
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
    local svelte_snippets = require("modules.snippets.svelte.snippets-svelte")
    local angular_snippets = require("modules.snippets.angular.snippets-angular")
    local typescript_snippets = require("modules.snippets.typescript.snippets-typescript")
    local util = require("modules.snippets.snippets-util")

    local is_angular = next(vim.fs.find({ "angular.json", "nx.json" }, { upward = true }))
    local is_svelte = next(vim.fs.find({ "svelte.config.js", "svelte.config.ts" }, { upward = true }))

    local wk = require("which-key")

    if is_angular then
      local angular_plus_ts = vim.tbl_extend("force", typescript_snippets, angular_snippets)
      wk.add(which_key_snippets(angular_plus_ts))
      ls.add_snippets("typescript", util.to_snippets(angular_plus_ts), { key = "typescript" })
      ls.add_snippets("html", util.to_snippets(angular_snippets), { key = "html" })
    elseif is_svelte then
      wk.add({
        { "<leader>ms", group = "Svelte", icon = { icon = "", color = "orange" } },
      })
      wk.add(which_key_generators())
      wk.add(which_key_snippets(svelte_snippets))
      wk.add(which_key_snippets(typescript_snippets))
      ls.add_snippets("svelte", util.to_snippets(svelte_snippets), { key = "svelte" })
      ls.add_snippets("typescript", util.to_snippets(typescript_snippets), { key = "typescript" })
    else
      wk.add(which_key_snippets(typescript_snippets))
      ls.add_snippets("typescript", util.to_snippets(typescript_snippets), { key = "typescript" })
    end
  end,
}

return M
