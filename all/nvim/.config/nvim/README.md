# nvim

Native-first Neovim `0.12+` config.

## plugins

Small set via `vim.pack`:
- `oil.nvim`
- `catppuccin`
- `grapple.nvim`
- `mini.completion`
- `mini.snippets`
- `mini.pairs`
- `mini.jump2d`
- `mini.diff`
- `mini.surround`
- `mini.clue`
- `mini.bufremove`
- `mini.statusline`
- `mini.cursorword`
- `mini.hipatterns`
- `mini.indentscope`
- `easyjump.tmux`
- `snacks.nvim` (picker only)

## notes

- LSP is native. See `lsp/README.md`.
- Treesitter is native. See `treesitter/README.md`.
- Large-file guards disable expensive features.
- Tmux + pi workflow is built in.
- `mini.clue` gives which-key style next-key hints for leader and common built-ins.

## useful keys

- `-` open Oil
- `<leader><space>` smart file picker
- `<leader>/` project grep
- `<leader>e` open Oil float
- `<C-h/j/k/l>` move between nvim splits and tmux panes
- `<C-n>` / `<C-p>` next/previous tmux window
- `<leader>tt` open and focus a plain tmux shell split beside Neovim
- `<C-]>` EasyJump in Neovim and tmux panes
- `<C-s>` save current buffer
- `<C-q>` save all and quit Neovim
- `gcc`, `gc{motion}`, visual `gc` comment toggle
- `gV` reselect last changed or yanked text
- visual `g/` search inside selection
- `ysiw(`, `ds"`, `cs"'`, visual `S` surround
- `s` then 2 chars jump with `mini.jump2d`
- `[h`, `]h`, `[H`, `]H` git hunks
- `<leader>gd` toggle git diff overlay
- `<leader>0` grapple tag file
- `<leader>1..5` jump to grapple file
- `<C-s>` snippet picker in insert mode
  - uses Snacks picker via `vim.ui.select()`
- `<leader>ms` snippet picker from normal mode
- `<leader>gk` / `<leader>gn` / `<leader>gx` / `<leader>g/` / `<leader>gp` set sub-mode
- normal `<Tab>` / `<S-Tab>` run the current sub-mode action
- `<C-Space>` force completion
- insert/select `<Tab>` / `<S-Tab>` completion or snippet jump
- `<leader>pp` prompt pi
- `<leader>ps` send line/selection to pi
- `<leader>pf` focus pi pane

## docs

- `vision.md`
- `lsp/README.md`
- `treesitter/README.md`
