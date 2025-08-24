local M = {}

M.incline_hide_on_zen_mode = function(props)
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
end

return M
