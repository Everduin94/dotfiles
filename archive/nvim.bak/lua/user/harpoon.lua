local harpoon = require('harpoon')

local function drop_select(list_item, list, options)
  local Extensions = require("harpoon.extensions")
  local Logger = require("harpoon.logger")

  Logger:log(
  "term_config#select",
  list_item,
  list.name,
  options
  )

  options = options or {}

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
  elseif options.drop then
    vim.cmd("drop " .. list_item.value)
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



-- TODO Duplicate code
local function term(list_item, list, options)
  local Extensions = require("harpoon.extensions")
  local Logger = require("harpoon.logger")

  Logger:log(
  "term_config#select",
  list_item,
  list.name,
  options
  )

  options = options or {}

  -- Terminal
  if list_item == nil then
    vim.cmd("terminal")
    require("harpoon"):list("term"):append()
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

harpoon:setup({
    default = {
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
        key = function()
            return vim.loop.cwd()
        end,
      },
      select = drop_select
    },
    term = {
      select_with_nil = true,
      encode = false,
      select = term,
    }
})

