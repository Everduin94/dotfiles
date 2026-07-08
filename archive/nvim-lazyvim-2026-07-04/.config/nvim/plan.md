# Plan: Investigate tabs/spaces change on save

## Status

Completed on 2026-05-27.

## Goal

Find why TypeScript/JS formatting changes tabs vs spaces on save after adding `oxfmt`/`oxlint`.

## Findings

1. Prettier/ESLint LazyVim extras are no longer active.
2. In `cx-platform-ui`, before the patch, `LazyFormat` resolved to LSP formatting through `ts_ls`; no Conform formatter was active for TypeScript.
3. `oxfmt` was not the save formatter, so `ts_ls` was the source changing indentation on save.
4. `cx-platform-ui/.editorconfig` sets `indent_style = tab`, and Neovim correctly opened TS buffers with `expandtab=false`.
5. Oxfmt reads `.editorconfig` only when its working directory is the project root; Conform's built-in `oxfmt` formatter only rooted on `.oxfmtrc*`, so without an `.oxfmtrc` it could miss `.editorconfig` if Neovim cwd was elsewhere.

## Implementation

1. Added `oxfmt` as the Conform formatter for Oxc-supported JS/TS/CSS/JSON/etc. filetypes so save formatting uses `oxfmt` before LSP fallback.
2. Overrode Conform `oxfmt.cwd` to root on `.oxfmtrc*`, `.editorconfig`, package files, lockfiles, `nx.json`, or `.git` so project formatting rules are picked up.
3. Kept built-in `nvim-lspconfig` `oxfmt`/`oxlint` servers and made their root detection use the same project markers.

## Validation

- `nvim --headless +qa`: ok.
- In `cx-platform-ui` TS file, Conform now resolves active formatter `oxfmt` with cwd `/Users/everduin/dev/cx-platform-ui-worktrees/cx-platform-ui`; LSP fallback is inactive.
- Temp project with `.editorconfig` `indent_style = tab`: `LazyFormat` saved TS with tabs, confirming `oxfmt` picked up project cwd/rules.

---

# Plan: Oxfmt + Oxlint Neovim config

## Status

Completed on 2026-05-27.

## Research

- Oxfmt Neovim docs recommend installing `oxfmt` and enabling the built-in nvim-lspconfig server with `vim.lsp.enable("oxfmt")`.
- `nvim-oxlint` docs show Lazy.nvim setup as `{ "soulsam480/nvim-oxlint", opts = {} }`.
- Current config enables LSPs manually in `lua/config/autocmds.lua` and collects plugin specs through `lua/modules/language_servers/language_servers-core.lua`.
- Current `lazyvim.json` enables Prettier and ESLint extras, which would keep those tools active alongside Oxfmt/Oxlint.

## Implementation

1. Added `oxfmt` and `oxlint` to the LazyVim/nvim-lspconfig `servers` table, which configures/enables the built-in nvim-lspconfig servers without duplicating manual `vim.lsp.enable()` calls.
2. Removed `soulsam480/nvim-oxlint` because it expects stale/internal `oxc_language_server`; modern nvim-lspconfig uses `oxlint --lsp`.
3. Removed LazyVim Prettier/ESLint extras so JS/TS lint/format defaults move to Oxc tooling.
4. Removed `nvim-oxlint` from `lazy-lock.json`.

## Validation

- `jq . lazyvim.json`: ok.
- `nvim --headless +qa`: ok.
- `nvim --headless '+lua require("lazy").load({ plugins = { "nvim-lspconfig" } }); print(vim.inspect(vim.lsp.config.oxfmt ~= nil))' +qa`: printed `true`.
- `nvim --headless '+lua require("lazy").load({ plugins = { "nvim-lspconfig" } }); print(vim.inspect(vim.lsp.config.oxlint ~= nil))' +qa`: printed `true`.
- Confirmed `nvim-oxlint` is no longer in the active Lazy.nvim plugin spec.

---

# Plan: Neovim 0.12 errors + Enter indentation regression

## Status

Executed on 2026-05-19.

## Completed repair

1. **Reinstalled stale Treesitter plugins without destructive git commands**
   - Moved old plugin dirs to backups instead of deleting them:
     - `~/.local/share/nvim/lazy-backups/treesitter-repair-20260519-153442/nvim-treesitter`
     - `~/.local/share/nvim/lazy-backups/treesitter-repair-20260519-153442/nvim-treesitter-textobjects`
   - Reinstalled/updated via Lazy.
   - Verified lockfile now points at `main` commits:
     - `nvim-treesitter`: `4916d6592ede8c07973490d9322f187e07dfefac`
     - `nvim-treesitter-textobjects`: `851e865342e5a4cb1ae23d31caf6e991e1c99f1e`

2. **Fixed related stale Mason plugins exposed by LazyVim update**
   - Same reversible backup approach:
     - `~/.local/share/nvim/lazy-backups/mason-lspconfig-repair-20260519-153621/mason-lspconfig.nvim`
     - `~/.local/share/nvim/lazy-backups/mason-repair-20260519-153705/mason.nvim`
   - Verified lockfile now points at compatible `main` commits:
     - `mason.nvim`: `cbf8d285e1462dd24acf3507817be2bbcb035919`
     - `mason-lspconfig.nvim`: `7b01e2974a47d489bb92f47a41e4c0088ea8f86e`

3. **Installed required Treesitter CLI**
   - `nvim-treesitter` `main` requires modern `tree-sitter build`.
   - Existing `tree-sitter` command was an old Yarn global CLI: `0.20.7`.
   - Installed Homebrew `tree-sitter-cli`.
   - Verified: `tree-sitter 0.26.8`.

4. **Installed Treesitter parsers**
   - Ran `require('nvim-treesitter').install(...):wait(...)` for LazyVim's `ensure_installed` list.
   - Result: `Installed 29/29 languages`.

5. **Fixed Autolist mapping leak**
   - Changed `lua/modules/util/util-core.lua` so Autolist mappings are buffer-local for markdown/text-like buffers.
   - Verified opening markdown then switching to TypeScript leaves no `<CR>` mapping in TypeScript.

## Validation results

- `nvim --headless +qa`: no errors.
- Markdown file with fenced code block: no `markview.nvim` / Treesitter `range` errors.
- TypeScript Enter behavior: new line keeps current indent.
- TypeScript after opening markdown: no leaked Autolist `<CR>` mappings.
- Markdown still has buffer-local Autolist `<CR>` mappings.

## Original findings

1. **Neovim version**
   - Current Neovim is `v0.12.2`.

2. **Treesitter / Markview error root cause**
   - Neovim 0.12 Treesitter query callbacks now pass captures as `TSNode[]` lists, not a single `TSNode`.
   - Current stale `markview.nvim`/`nvim-treesitter` code assumed a single node.
   - The active bad stack trace pointed at old `nvim-treesitter` code:
     - `~/.local/share/nvim/lazy/nvim-treesitter/lua/nvim-treesitter/query_predicates.lua:141`

3. **Enter indentation root cause**
   - Before repair, TypeScript had old `indentexpr=nvim_treesitter#indent()` and Enter created the new line at column 0.
   - After moving to the new `nvim-treesitter` main branch, TypeScript uses `v:lua.LazyVim.treesitter.indentexpr()` and preserves indent.

4. **Secondary issue: Autolist leaked `<CR>` mappings globally**
   - Fixed by making mappings buffer-local.

## Files changed

- `lazy-lock.json`
- `lua/modules/util/util-core.lua`

No plugin source under `~/.local/share/nvim/lazy/*` was patched directly.
