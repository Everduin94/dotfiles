local M = {}

local function use_native_insert(snippet)
  vim.snippet.expand(snippet.body)
end

local function lang_patterns()
  local typescript = { "typescript/**/*.json", "**/typescript.json" }
  local markdown = { "markdown/**/*.json", "**/markdown.json" }

  return {
    typescript = typescript,
    typescriptreact = typescript,
    tsx = typescript,
    htmlangular = { "htmlangular/**/*.json", "**/htmlangular.json" },
    markdown = markdown,
  }
end

function M.pick()
  MiniSnippets.expand({ match = false })
end

function M.setup()
  local mini_snippets = require("mini.snippets")
  local gen_loader = mini_snippets.gen_loader

  mini_snippets.setup({
    snippets = {
      gen_loader.from_lang({
        lang_patterns = lang_patterns(),
        silent = true,
      }),
      gen_loader.from_file(".vscode/project.code-snippets", { silent = true }),
    },
    mappings = {
      expand = "",
      jump_next = "",
      jump_prev = "",
      stop = "",
    },
    expand = {
      insert = use_native_insert,
    },
  })

  MiniSnippets.start_lsp_server({ match = false })

  vim.keymap.set({ "i", "s" }, "<C-s>", M.pick, { desc = "Snippet picker" })
end

return M
