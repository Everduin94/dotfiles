local capabilities = vim.lsp.protocol.make_client_capabilities()

if capabilities.workspace then
  capabilities.workspace.didChangeWatchedFiles = nil
end

vim.lsp.config("*", {
  capabilities = capabilities,
})

vim.lsp.enable({
  "ts_ls",
  "html",
  "cssls",
  "angularls",
  "svelte",
  "tailwindcss",
  "eslint",
  "lua_ls",
})

-- Native replacement for nvim-lspconfig's `:LspRestart`. Stops the clients
-- attached to the current buffer (or every client with `!`), waits for them
-- to fully shut down, then re-fires the `FileType` autocmd that
-- `vim.lsp.enable()` itself listens on (see `nvim.lsp.enable` augroup in
-- runtime/lua/vim/lsp.lua) so the matching config(s) restart on their own.
vim.api.nvim_create_user_command("LspRestart", function(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = opts.bang and vim.lsp.get_clients() or vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    vim.notify("LspRestart: no active clients", vim.log.levels.WARN)
    return
  end

  local names, ids = {}, {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
    table.insert(ids, client.id)
    client:stop(true)
  end

  local timer = assert(vim.uv.new_timer())
  timer:start(
    100,
    100,
    vim.schedule_wrap(function()
      for _, id in ipairs(ids) do
        if vim.lsp.get_client_by_id(id) then
          return -- still shutting down, check again next tick
        end
      end

      timer:stop()
      timer:close()
      vim.cmd.doautoall("nvim.lsp.enable FileType")
      vim.notify("LspRestart: restarted " .. table.concat(names, ", "))
    end)
  )
end, {
  bang = true,
  desc = "Restart LSP clients (current buffer; use ! for every client)",
})
