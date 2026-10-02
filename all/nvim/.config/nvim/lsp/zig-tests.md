# zig tests (neotest)

Run the Zig test under the cursor with `<leader>rr`.

## keys

- `<leader>rr` test under cursor
- `<leader>rf` file
- `<leader>rl` last
- `<leader>rx` stop
- `<leader>ro` output float, `<leader>rO` output panel
- `<leader>rs` summary

## setup

1. Neovim 0.12+.
2. `zig` on `PATH` (`brew install zig`). Match `.minimum_zig_version` in the project's `build.zig.zon`.
3. Tree-sitter parser: `brew install tree-sitter-cli`, then `install/nvim-treesitter-parsers.sh`.
4. Open nvim once so `vim.pack` installs neotest, nvim-nio, plenary.nvim.

Check: `zig version`, and `nvim --headless "+lua print(vim.treesitter.language.add('zig'))" +qa` prints `true`.

Not loaded in `PI_NVIM_INLINE=1` mode.

## how it works

- Adapter: `lua/neotest-zig-build/init.lua`. The stock `lawrence-laz/neotest-zig` only works on Zig <= 0.14, so it isn't used.
- It runs `zig build test` with a filter for the test name. A small wrapper (`zig/neotest_build.zig`) is copied next to `build.zig` for the run, then deleted.
- Files with no `build.zig` run through `zig/neotest_standalone.zig`.
- Pass/fail is read from the `zig build` output.

## changing Zig versions

Same on any version: the nvim side, keymaps, the tree-sitter query, the `zig build` flags used.

May break on a new version (e.g. nightly):
- The two `.zig` files in `zig/`, if `std.Build` changed. Symptom: every test shows a build error.
- The output patterns in `_parse` (`lua/neotest-zig-build/init.lua`), if Zig's output format changed. Symptom: build works but statuses are wrong.
- The `zig` parser, if new syntax isn't recognized. Re-run `install/nvim-treesitter-parsers.sh`.

If it fails, run it by hand:

```sh
cd <project>
cp ~/.config/nvim/zig/neotest_build.zig .neotest_build.zig
zig build test --color off --summary all --build-file .neotest_build.zig -Dneotest-filter='.test.my test name'
rm .neotest_build.zig
```

A compile error here means the wrapper needs updating. A clean run with wrong statuses in nvim means `_parse` needs updating.

## gotchas

- Only tests reachable from the project's `test` step run. A file not imported by the build can show a false pass.
- The project needs a `test` step.
- Filters match by substring, so `"adds"` also runs `"adds badly"`.
- A compile error in a file fails every test in that run.
- If nvim is killed mid-run, delete the leftover `.neotest_build.zig`.
- No debugger support.
- Logs: `~/.local/state/nvim/neotest.log`.
