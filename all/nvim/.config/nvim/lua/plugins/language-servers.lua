return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        markdownlint = {
          args = { "--disable", "MD013", "--" },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        svelte = {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = vim.fn.has("nvim-0.10") == 0 and { dynamicRegistration = true },
            },
          },
          plugin = {
            svelte = {
              format = {
                config = {
                  svelteBracketNewLine = false, -- Disable svelteBracketNewLine
                },
              },
            },
          },
        },
      },
      setup = {
        svelte = function(_, opts)
          print("I am running this code!")
          LazyVim.lsp.on_attach(function(client, buffer)
            vim.api.nvim_create_autocmd("BufWritePost", {
              pattern = { "*.js", "*.ts" },
              callback = function(ctx)
                client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
              end,
            })
          end)
          opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
            svelte = {
              plugin = {
                svelte = {
                  format = {
                    config = {
                      svelteBracketNewLine = false,
                    },
                  },
                },
              },
            },
          })
        end,
      },
    },
  },
}
