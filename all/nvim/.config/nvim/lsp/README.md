# native lsp

## install

- macOS:
  - `brew install lua-language-server`
- global npm servers:
  - `npm install -g typescript typescript-language-server vscode-langservers-extracted @angular/language-server svelte-language-server @tailwindcss/language-server`
- workspace deps for JS/TS projects:
  - `npm install -D eslint prettier @fsouza/prettierd @typescript-eslint/parser @typescript-eslint/eslint-plugin`

## notes

- no Mason here. install servers outside Neovim.
- `eslint` uses `vscode-eslint-language-server` from `vscode-langservers-extracted`.
- `angularls` uses `ngserver` from `@angular/language-server`.
- local `node_modules/.bin` is preferred. global PATH is fallback.

## uses

- `ts_ls` -> `typescript-language-server`
  - function call parens / placeholders come from `ts_ls` via `settings.completions.completeFunctionCalls = true`
  - accepted function/method completion items can expand as snippets like `doThing(${1:arg})`
- `html` -> `vscode-html-language-server`
- `cssls` -> `vscode-css-language-server`
- `eslint` -> `vscode-eslint-language-server`
- `angularls` -> `ngserver`
- `svelte` -> `svelteserver`
- `tailwindcss` -> `tailwindcss-language-server`
- `lua_ls` -> `lua-language-server`

## save behavior

- ESLint fixes run first
- Prettier / prettierd runs after that
- `ts_ls` formatting is disabled

## verify

- test JS/TS function call completion in a project file and accept a function item from the menu

- `lua-language-server --version`
- `tsc --version`
- `typescript-language-server --version`
- `command -v ngserver`
- `command -v vscode-eslint-language-server`
- `:checkhealth vim.lsp`
- `:LspEslintFixAll`
