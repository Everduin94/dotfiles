# nvim

Native-first Neovim `0.12+` config.

## plugins

Small set via `vim.pack`:
- `oil.nvim`
- `tokyonight.nvim`, `kanagawa.nvim`, `catppuccin`, `nightfox.nvim`
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
- `snacks.nvim` (picker, Hunk terminal)
- `neotest` (+ `nvim-nio`, `plenary.nvim`) with an in-config Zig adapter (`lua/neotest-zig-build`)
- `mini.animate`
- `codecompanion.nvim` (chat and inline edits through pi, via `pi-acp`)
- `markview.nvim` (renders markdown and the chat)

## notes

- LSP is native. See `lsp/README.md`.
- Treesitter is native. See `treesitter/README.md`.
- Large-file guards disable expensive features.
- The default theme is `tokyonight-moon-minimal`: most code is plain, and color marks declarations, types, literals, and parameters. See `lua/config/colors.lua`.
- `mini.clue` gives which-key style next-key hints for leader and common built-ins.

## useful keys

- `-` open Oil in a left panel; picking a file closes it
- `<C-c>` / `q` in Oil close the panel
- `<leader><space>` case-insensitive file picker
- `<leader>/` case-insensitive project grep
- `<leader>e` toggle the left-side Oil float
- `<C-h/j/k/l>` move between Neovim splits
- `<leader>t1..4` open or focus a terminal in a shared right split
- terminal `<Esc>` leave terminal mode
- `<leader>ut` toggle the default and last theme, `<leader>uc` pick with preview, `<leader>un` / `<leader>uN` next / previous
- `<leader>uy` white types, `<leader>up` blue params, `<leader>uk` muted keywords (minimal themes)
- `<leader>um` markdown side-by-side, `<leader>uM` markdown rendering, `<leader>uB` code block bar
- `<leader>us` one statusline or one per window
- `<leader>ub` darker bg for the chat, terminals, and Oil
- `<leader>uT` / `:TermOpacity [toggle|on|off]` toggle Ghostty window transparency (`bin/ghostty-opacity`)
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
- `<leader>ac` toggle the last chat, `<leader>an` new chat, `}` / `{` cycle chats, `<leader>aA` actions and open chats
- `<leader>at` send position or selection, `<leader>af` send file, visual `<leader>av` send selection (not submitted)
- `<leader>ai` inline edit with pi, reviewed as a diff
- `ga` in a chat changes the model

## zig tests

- `<leader>rr` runs the test under the cursor. Setup, Zig version notes and troubleshooting: `lsp/zig-tests.md`.

## docs

- `vision.md`
- `lsp/README.md`
- `lsp/zig-tests.md`
- `treesitter/README.md`
