local M = {}

M.current = "Buffer"

local modes = {
  Buffer = {
    icon = "󰀘",
    next = function()
      vim.cmd.bnext()
    end,
    prev = function()
      vim.cmd.bprevious()
    end,
  },
  ["Quick Fix"] = {
    icon = "",
    enter = function()
      pcall(vim.cmd.copen)
    end,
    next = function()
      if pcall(vim.cmd.cnext) then
        vim.cmd.normal({ args = { "zz" }, bang = true })
      end
    end,
    prev = function()
      if pcall(vim.cmd.cprevious) then
        vim.cmd.normal({ args = { "zz" }, bang = true })
      end
    end,
  },
  Git = {
    icon = "󰊢",
    enter = function()
      if not _G.MiniDiff then
        return
      end

      pcall(MiniDiff.goto_hunk, "next")
      pcall(MiniDiff.goto_hunk, "prev")
    end,
    next = function()
      if _G.MiniDiff then
        pcall(MiniDiff.goto_hunk, "next")
      end
    end,
    prev = function()
      if _G.MiniDiff then
        pcall(MiniDiff.goto_hunk, "prev")
      end
    end,
  },
  Diagnostic = {
    icon = "󱩔",
    enter = function()
      vim.diagnostic.jump({ count = 1, float = true })
    end,
    next = function()
      vim.diagnostic.jump({ count = 1, float = true })
    end,
    prev = function()
      vim.diagnostic.jump({ count = -1, float = true })
    end,
  },
  Spellcheck = {
    icon = "󰓆",
    enter = function()
      vim.cmd.normal({ args = { "]s" }, bang = true })
    end,
    next = function()
      vim.cmd.normal({ args = { "]s" }, bang = true })
    end,
    prev = function()
      vim.cmd.normal({ args = { "[s" }, bang = true })
    end,
  },
}

local function mode(name)
  return modes[name] or modes.Buffer
end

function M.set(name)
  if not modes[name] then
    return
  end

  M.current = name
  vim.cmd.redrawstatus()
end

function M.activate(name)
  M.set(name)

  local target = mode(name)
  if target.enter then
    target.enter()
  end
end

function M.next()
  mode(M.current).next()
end

function M.prev()
  mode(M.current).prev()
end

function M.icon()
  return mode(M.current).icon or ""
end

function M.setup()
  local map = vim.keymap.set

  map("n", "<Tab>", M.next, { desc = "Sub mode next" })
  map("n", "<S-Tab>", M.prev, { desc = "Sub mode previous" })

  map("n", "<leader>gk", function()
    M.activate("Git")
  end, { desc = "Git Hunk Mode" })

  map("n", "<leader>gn", function()
    M.activate("Diagnostic")
  end, { desc = "Diagnostic Mode" })

  map("n", "<leader>gx", function()
    M.activate("Quick Fix")
  end, { desc = "Quick Fix Mode" })

  map("n", "<leader>g/", function()
    M.set("Buffer")
  end, { desc = "Buffer Mode" })

  map("n", "<leader>gp", function()
    M.activate("Spellcheck")
  end, { desc = "Spellcheck Mode" })
end

return M
