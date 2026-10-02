# native treesitter

## install

- deps:
  - `brew install tree-sitter-cli`
  - `git`
- install/update parsers + queries:
  - `~/dotfiles/install/nvim-treesitter-parsers.sh`

## parsers used

- `javascript`
- `typescript`
- `tsx`
  - used for `javascriptreact`
  - used for `typescriptreact`
- `html`
  - used for `html`
  - used for `htmlangular`
- `css`
- `scss`
- `svelte`
- `yaml`
- `lua`
  - built into Neovim

## disabled

- markdown files
- files over 1200 lines (`max_lines` in `lua/config/treesitter.lua`)
- files marked as large-file mode

## indentation

Core `vim.treesitter` only provides highlighting/folding, **not indentation**
(no `indentexpr` equivalent). Indent-on-type (`=`, `o`/`O`, autoindent) for a
treesitter language requires the `nvim-treesitter` plugin, which is the only
thing providing the `indentexpr()` function and the query predicates its
`indents.scm` files use.

- plugin: `nvim-treesitter/nvim-treesitter`, pinned to the `main` branch,
  added via `vim.pack` in `init.lua`.
- it is used **only** for `require('nvim-treesitter').indentexpr()`. Parser
  install/highlighting is still handled entirely by the script above; we
  never call the plugin's own `install()`.
- wired per-filetype in `lua/config/treesitter.lua` (`indentexpr_filetypes`):
  currently `svelte`, `astro`. Most useful for languages with embedded mixed
  syntax (html+js+css) where smartindent guesses badly. Add more filetypes
  to that table if needed (requires an `indents.scm` query to exist for the
  language, see `queries/<lang>/indents.scm` under `:echo stdpath('data')`).

## verify

- `:InspectTree`
- `:checkhealth vim.treesitter`
- indent: open a `.svelte` file, run `gg=G`, confirm nested html/js/css
  reindents correctly.
