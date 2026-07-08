local large_file_size = 1024 * 1024

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  callback = function()
    vim.highlight.on_yank({ timeout = 120 })
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Start in insert mode in terminal",
  callback = function()
    vim.cmd.startinsert()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_input",
  desc = "Disable completion in Snacks picker input",
  callback = function(args)
    vim.b[args.buf].minicompletion_disable = true
    vim.bo[args.buf].completefunc = ""
    vim.bo[args.buf].omnifunc = ""
  end,
})

vim.api.nvim_create_autocmd("BufReadPre", {
  desc = "Enable large file mode",
  callback = function(args)
    local name = vim.api.nvim_buf_get_name(args.buf)
    if name == "" then
      return
    end

    local stat = vim.uv.fs_stat(name)
    if not stat or stat.size < large_file_size then
      return
    end

    vim.b[args.buf].large_file = true
    vim.b[args.buf].minidiff_disable = true
    vim.b[args.buf].miniindentscope_disable = true
    pcall(function()
      require("mini.diff").disable(args.buf)
    end)

    vim.opt_local.foldmethod = "manual"
    vim.opt_local.list = false
    vim.opt_local.spell = false
    vim.opt_local.swapfile = false
    vim.opt_local.undofile = false
    vim.opt_local.wrap = false

    pcall(vim.treesitter.stop, args.buf)

    vim.schedule(function()
      vim.bo[args.buf].syntax = ""
      vim.notify_once("Large file mode: " .. vim.fn.fnamemodify(name, ":."), vim.log.levels.INFO)
    end)
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Native LSP keymaps",
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if vim.b[args.buf].large_file and client then
      client.server_capabilities.semanticTokensProvider = nil
    end

    if client and client.name == "ts_ls" then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end

    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "LSP definition")
    map("gr", vim.lsp.buf.references, "LSP references")
    map("gI", vim.lsp.buf.implementation, "LSP implementation")
    map("K", vim.lsp.buf.hover, "LSP hover")
    map("<leader>ca", vim.lsp.buf.code_action, "LSP code action")
    map("<leader>cr", vim.lsp.buf.rename, "LSP rename")
    map("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
    map("]d", vim.diagnostic.goto_next, "Next diagnostic")

    if package.loaded["mini.clue"] and _G.MiniClue then
      MiniClue.ensure_buf_triggers(args.buf)
    end
  end,
})
