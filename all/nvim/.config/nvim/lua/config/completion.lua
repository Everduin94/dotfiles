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

-- `vim.snippet.jump()` cannot run inside an expr mapping (textlock), and returning
-- "<Cmd>lua vim.snippet.jump(N)<CR>" does not survive the completion popup menu
-- being open: Neovim then inserts the raw keycodes verbatim, which is how the
-- literal text "vim.snippet.jump(1)" ended up in the buffer. Jump on the next
-- event-loop tick instead, cancelling the menu synchronously when it is open.
local function schedule_jump(direction)
  vim.schedule(function()
    vim.snippet.jump(direction)
  end)

  if vim.fn.pumvisible() == 1 then
    return key("<C-e>")
  end

  return ""
end

function M.snippet_forward()
  if vim.snippet.active({ direction = 1 }) then
    return schedule_jump(1)
  end

  if _G.MiniCompletion and MiniCompletion.scroll("down") then
    return ""
  end

  return key("<C-f>")
end

function M.snippet_backward()
  if vim.snippet.active({ direction = -1 }) then
    return schedule_jump(-1)
  end

  if _G.MiniCompletion and MiniCompletion.scroll("up") then
    return ""
  end

  return key("<C-b>")
end

function M.enter()
  -- Accept the popup selection, as before (a snippet item expands through
  -- mini.completion's `snippet_insert`).
  if vim.fn.pumvisible() == 1 and pum_selected() then
    return key("<C-y>")
  end

  -- Inside a snippet: step to the next placeholder. Also covers select mode,
  -- where <CR> used to replace the selected placeholder with a newline.
  if vim.snippet.active({ direction = 1 }) then
    return schedule_jump(1)
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
