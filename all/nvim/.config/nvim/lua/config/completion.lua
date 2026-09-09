local M = {}

local function pum_selected()
  return vim.fn.complete_info({ "selected" }).selected ~= -1
end

local function key(term)
  return vim.api.nvim_replace_termcodes(term, true, false, true)
end

function M.tab()
  if vim.fn.pumvisible() == 1 then
    return key("<C-n>")
  end

  return key("<Tab>")
end

function M.s_tab()
  if vim.fn.pumvisible() == 1 then
    return key("<C-p>")
  end

  return key("<S-Tab>")
end

function M.snippet_forward()
  if vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
    return ""
  end

  if _G.MiniCompletion and MiniCompletion.scroll("down") then
    return ""
  end

  return key("<C-f>")
end

function M.snippet_backward()
  if vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
    return ""
  end

  if _G.MiniCompletion and MiniCompletion.scroll("up") then
    return ""
  end

  return key("<C-b>")
end

function M.enter()
  if vim.fn.pumvisible() == 1 and pum_selected() then
    return key("<C-y>")
  end

  if _G.MiniPairs then
    return MiniPairs.cr()
  end

  return key("<CR>")
end

function M.setup_keymaps()
  vim.keymap.set({ "i", "s" }, "<Tab>", M.tab, { expr = true, desc = "Completion next" })
  vim.keymap.set({ "i", "s" }, "<S-Tab>", M.s_tab, { expr = true, desc = "Completion previous" })
  vim.keymap.set({ "i", "s" }, "<CR>", M.enter, { expr = true, desc = "Completion accept" })
  vim.keymap.set(
    { "i", "s" },
    "<C-f>",
    M.snippet_forward,
    { expr = true, desc = "Snippet jump forward / scroll down" }
  )
  vim.keymap.set(
    { "i", "s" },
    "<C-b>",
    M.snippet_backward,
    { expr = true, desc = "Snippet jump backward / scroll up" }
  )
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
