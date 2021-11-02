-- Add additional capabilities supported by nvim-cmp
local nvim_lsp = require('lspconfig')
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
-- local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver', 'sumneko_lua', 'angularls' }
-- for _, lsp in ipairs(servers) do
--   nvim_lsp[lsp].setup {
--     -- on_attach = my_custom_on_attach,
--     capabilities = capabilities,
--   }
-- end

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- luasnip setup
local luasnip = require 'luasnip'
local lspKind = require 'lspkind'
-- require("luasnip/loaders/from_vscode").load { paths = '~/.config/nvim/autoload/plugged/friendly-snippets' }
require("luasnip/loaders/from_vscode").load { paths = '~/.config/nvim/snips' }

-- IDK What this is but I'm using for vsnip call
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end


-- -- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  formatting = {
    format = lspKind.cmp_format({with_text = true, maxwidth = 150})
  },
  snippet = {
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-a>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<C-l>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      -- elseif vim.fn.call("vsnip#available", {1}) == 1 then
      --   return t "<Plug>(vsnip-expand-or-jump)"
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      -- if vim.fn.call("vsnip#jumpable", {-1}) == 1 then
      --   return t "<Plug>(vsnip-jump-prev)"
      elseif cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'luasnip' },
    { name = 'nvim_lsp',
    max_item_count = 100},
    -- { name = 'vsnip' },
  },
}
