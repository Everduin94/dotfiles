# nvim

Native-first Neovim `0.12+` config.

## plugins

Small set via `vim.pack`:
- `oil.nvim`
- `catppuccin`
- `kanso.nvim`
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
- `snacks.nvim` (picker and terminals)
- `neotest` (+ `nvim-nio`, `plenary.nvim`) with an in-config Zig adapter (`lua/neotest-zig-build`)

## notes

- LSP is native. See `lsp/README.md`.
- Treesitter is native. See `treesitter/README.md`.
- Large-file guards disable expensive features.
- Snacks terminals + zmx session workflow is built in.
- `mini.clue` gives which-key style next-key hints for leader and common built-ins.

## useful keys

- `-` open Oil
- `<C-c>` close Oil and restore the previous buffer
- `<leader><space>` case-insensitive file picker
- `<leader>/` case-insensitive project grep
- `<leader>e` toggle the left-side Oil float
- `<C-h/j/k/l>` move between Neovim splits
- `<leader>t1..4` open persistent terminal buffers in the current window (split first if wanted)
- terminal `<Esc>` leave terminal mode
- `<leader>tg` toggle the managed zmx chooser/session terminal
- `<leader>td` detach zmx and return to its session chooser
- `<leader>tf` paste the current file path into the attached zmx session
- visual `<leader>ts` paste selection into the attached zmx session
- `<leader>tf` and `<leader>ts` do not submit; edit the pasted input before pressing Enter
- `<leader>ut` / `:Theme [name]` toggle catppuccin <-> kanso (persisted in nvim state dir)
- `<leader>uT` / `:TermOpacity [toggle|on|off]` toggle Ghostty window transparency (`bin/ghostty-opacity`)
- zmx terminal `<C-c>` sends Esc to pi (stop); double-tap sends real `^C`; `<leader>ax` same from any buffer
- terminal `<C-g>` in pi opens the prompt editor as a float in this nvim (`bin/pi-nvim-edit`, `lua/config/pi_edit.lua`); `:wq` / `<C-s>` sends
- `<leader>rr` run the test under the cursor (Zig, via neotest); `rf` file, `rl` last, `rx` stop, `ro` output float, `rO` output panel, `rs` summary
- `<C-s>` save current buffer
- `<C-q>` save all and quit Neovim
- `gcc`, `gc{motion}`, visual `gc` comment toggle
- `gV` reselect last changed or yanked text
- visual `g/` search inside selection
- `ysiw(`, `ds"`, `cs"'`, visual `S` surround
- `s` then 2 chars jump case-insensitively with `mini.jump2d`
- `:wd` delete the current buffer while preserving the window layout (`:wd!` forces)
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
- `<leader>ap` prompt the managed zmx terminal
- `<leader>at` / `<leader>af` send current position / file path to zmx
- visual `<leader>av` also sends selection to zmx during transition

## zig tests

- `<leader>rr` runs the test under the cursor. Setup, Zig version notes and troubleshooting: `lsp/zig-tests.md`.

## docs

- `vision.md`
- `lsp/README.md`
- `lsp/zig-tests.md`
- `treesitter/README.md`
