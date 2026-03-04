local M = {}

vim.api.nvim_create_user_command("GitRelativePath", function()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if git_root == nil or git_root == "" then
    vim.notify("Not inside a git repository", vim.log.levels.ERROR)
    return
  end

  local buf_path = vim.api.nvim_buf_get_name(0)
  local rel_path = vim.fn.fnamemodify(buf_path, ":."):gsub("^" .. vim.pesc(git_root .. "/"), "")

  vim.fn.setreg("+", rel_path)
  vim.notify("Copied to clipboard: " .. rel_path, vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("CopyPRMarkdown", function()
  local result = vim.fn.system("gh pr view --json url,title")
  if vim.v.shell_error ~= 0 then
    vim.notify("No PR found for current branch", vim.log.levels.ERROR)
    return
  end

  local ok, data = pcall(vim.json.decode, result)
  if not ok or not data or not data.url or not data.title then
    vim.notify("Failed to parse PR data", vim.log.levels.ERROR)
    return
  end

  local markdown = "[Pull Request - " .. data.title .. "](" .. data.url .. ")"
  vim.fn.setreg("+", markdown)
  vim.notify("Copied to clipboard: " .. markdown, vim.log.levels.INFO)
end, {})

vim.keymap.set("n", "<leader>ps", ":%s/", { noremap = true, desc = "Substitue on entire buffer" })
vim.keymap.set("v", "<leader>ps", ":s/", { noremap = true, desc = "Substitue on selection (use /g)" })

vim.keymap.set("n", "<leader>p0", '"0p', { desc = "Paste from 0 register" })
vim.keymap.set("n", "<leader>p1", '"1p', { desc = "Paste from 1 register" })

vim.keymap.set(
  "n",
  "<leader>pg",
  "<cmd>GitRelativePath<CR>",
  { desc = "Copy current file name to clipboard from git root" }
)

vim.keymap.set("n", "<leader>pr", "<cmd>CopyPRMarkdown<CR>", { desc = "Copy PR markdown link" })

return M
