# vision

## goals

- Target Neovim `0.12+` only.
- Use native Neovim features first.
- Keep startup small, fast, and understandable.
- Install as few plugins as possible.
- Configure plugins minimally.
- Manage third-party dependencies outside Neovim when possible.
- Stay usable in large files.
- Integrate cleanly with tmux and pi.

## principles

1. Native over plugin.
   - Use built-in LSP, diagnostics, packages, filetype, quickfix, and terminal features before adding plugins.
2. External over auto-managed.
   - Install language servers, tree-sitter parsers, formatters, linters, tmux, and CLI tools outside Neovim.
3. Small over clever.
   - Prefer a few flat Lua files over a framework or deep abstraction.
4. Fast over flashy.
   - No heavy UI layer.
   - No plugin sprawl.
   - No background installers.
5. Safe for big files.
   - Default to large-file guards.
   - Avoid tree-sitter highlighting by default.
   - Disable expensive features when file size crosses a threshold.
6. Tmux is part of the editor workflow.
   - Move between Neovim splits and tmux panes with the same keys.
   - Send prompts or selections to pi through tmux.

## non-goals

- Rebuilding LazyVim with native code.
- Chasing feature parity with plugin-heavy setups.
- Managing every tool install from inside Neovim.
- Adding telescope, treesitter, mason, or a completion framework unless there is a clear need.

## first slice

- Replace LazyVim with a native-first config.
- Use `vim.pack` instead of a plugin manager.
- Add only `oil.nvim` as the first plugin experiment.
- Keep tmux navigation and pi messaging built in.
- Add large-file protections early.

## expected layout

- `init.lua`
- `lua/config/options.lua`
- `lua/config/autocmds.lua`
- `lua/config/keymaps.lua`
- `lua/config/tmux.lua`
- `vision.md`

## plugin bar

A plugin should usually meet at least one of these:

- Replaces a lot of custom code with a very small dependency.
- Exposes functionality Neovim does not have natively.
- Improves UX without adding noticeable startup or runtime cost.
- Works well in large files or can be disabled cheaply.

If it fails that bar, do not install it.

## resources

- [Vim Pack](https://neovim.io/doc/user/pack/)
- `:help vim.pack`
- `:help packages`
- `:help lua-guide`
- `:help diagnostic`
- `:help lsp`
- `:help api`
- `:help vim.system()`
- `man tmux`

## notes

- Commit `nvim-pack-lock.json` once it is generated.
- Prefer adding native LSP configs under local `lsp/*.lua` files instead of pulling in a framework.
- If a module starts getting big, split it or delete complexity.
