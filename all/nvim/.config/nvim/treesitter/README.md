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
- files over 2000 lines
- files marked as large-file mode

## verify

- `:InspectTree`
- `:checkhealth vim.treesitter`
