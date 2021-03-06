-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'


-- luasnip setup
local luasnip = require 'luasnip'
local lspKind = require 'lspkind'
require("luasnip/loaders/from_vscode").load { paths = '~/.config/nvim/snips' }

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  formatting = {
    format = lspKind.cmp_format({with_text = true, maxwidth = 150})
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = function()
      if luasnip.jumpable(1) then
        luasnip.jump(1)
      end
    end,
    ['<C-a>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<C-f>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      -- jump, else, next item
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'luasnip' },
    { name = 'nvim_lsp',
    max_item_count = 100},
    { name = 'buffer' },
    { name = 'path' }
  },
}
