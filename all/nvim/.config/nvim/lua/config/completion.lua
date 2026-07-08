local M = {}

local function pum_selected()
  return vim.fn.complete_info({ "selected" }).selected ~= -1
end

local function key(term)
  return vim.api.nvim_replace_termcodes(term, true, false, true)
end

local function snippet_jump(direction)
  if not vim.snippet.active({ direction = direction }) then
    return nil
  end

  return key(string.format("<Cmd>lua vim.snippet.jump(%d)<CR>", direction))
end

function M.tab()
  local jump = snippet_jump(1)
  if jump then
    return jump
  end

  if vim.fn.pumvisible() == 1 then
    return key("<C-n>")
  end

  return key("<Tab>")
end

function M.s_tab()
  local jump = snippet_jump(-1)
  if jump then
    return jump
  end

  if vim.fn.pumvisible() == 1 then
    return key("<C-p>")
  end

  return key("<S-Tab>")
end

function M.enter()
  if vim.fn.pumvisible() == 1 and pum_selected() then
    return key("<C-y>")
  end

  return key("<CR>")
end

function M.setup_keymaps()
  vim.keymap.set({ "i", "s" }, "<Tab>", M.tab, { expr = true, desc = "Completion next / snippet next" })
  vim.keymap.set({ "i", "s" }, "<S-Tab>", M.s_tab, { expr = true, desc = "Completion previous / snippet previous" })
  vim.keymap.set({ "i", "s" }, "<CR>", M.enter, { expr = true, desc = "Completion accept" })
end

function M.setup()
  local mini_completion = require("mini.completion")

  mini_completion.setup({
    delay = {
      completion = 100,
      info = 100,
      signature = 50,
    },
    window = {
      info = { border = "rounded" },
      signature = { border = "rounded" },
    },
    lsp_completion = {
      auto_setup = true,
      snippet_insert = function(snippet)
        vim.snippet.expand(snippet)
      end,
    },
    mappings = {
      force_twostep = "<C-Space>",
      force_fallback = "",
      scroll_down = "<C-f>",
      scroll_up = "<C-b>",
    },
  })

  M.setup_keymaps()
end

return M
