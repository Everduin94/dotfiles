-- npm install -g typescript typescript-language-server
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      'documentation',
      'detail',
      'additionalTextEdits',
    }
  }
-- require'lspconfig'.tsserver.setup {
--   init_options = {
--       maxTsServerMemory = 12288,
--     },
--   capabilities = capabilities,
-- 	on_attach = function(client)
-- 		-- let prettier do the formatting
-- 		client.resolved_capabilities.document_formatting = false
-- 		client.resolved_capabilities.document_range_formatting = false
-- 	end
-- }

-- TODO (08/25/2022 - 10:54pm): Testing
require("typescript").setup({
  server = {
    init_options = {
        maxTsServerMemory = 12288,
      },
    capabilities = capabilities,
    on_attach = function(client)
      -- let prettier do the formatting
      client.server_capabilities.documentFormattingProvider = false
    end
  }
})
