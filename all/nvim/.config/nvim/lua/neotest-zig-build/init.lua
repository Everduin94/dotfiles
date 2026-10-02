-- neotest adapter for Zig (0.16+), driven through `zig build`.
--
-- Why not lawrence-laz/neotest-zig: it ships its own test runner written against
-- Zig 0.14 (`std.io.getStdErr` etc.), which no longer compiles on 0.16.
--
-- How it works
--   * Discovery: tree-sitter (`zig` parser) finds `test "name"` / `test decl`.
--   * Projects with a build.zig: `zig/neotest_build.zig` is copied next to build.zig
--     for one run and used as `--build-file`. It runs the project's own build()
--     and then applies `-Dneotest-filter` to every test compile step under the
--     `test` step, so named modules / dependencies keep working.
--   * Loose files (no build.zig): `zig/neotest_standalone.zig` builds just that file.
--   * Single file / single test runs where the project `test` step executes no tests
--     at all (file not reachable from it): the file is retried on its own, i.e. what
--     `zig test <file>` does. Only used as a fallback, so projects that need their
--     build.zig modules keep working through the wrapper.
--   * Results are read from the build runner's output: failures are printed as
--     `error: '<file>.test.<name>' failed:` (or `... leaked`); everything else that
--     ran is a pass. The wrapper sets `has_side_effects` on test run steps so the
--     test binaries always re-execute: a *cached* run step prints no test counts at
--     all, and their absence is what tells us nothing ran. Compiles stay cached.
--
-- Limits: filters are substring matches on `<stem>.test.<name>`, so a sibling whose
-- name contains the selected one also runs (and is reported correctly). Tests
-- only run if the file is reachable from the project's `test` step.
local lib = require("neotest.lib")
local nio = require("nio")

local M = { name = "neotest-zig-build" }

local assets_dir = vim.fn.stdpath("config") .. "/zig"
local standalone_dir = vim.fn.stdpath("cache") .. "/neotest-zig-build"
local wrapper_name = ".neotest_build.zig"

local test_query = [[
;; string-named tests
(test_declaration
  (string (string_content) @test.name)) @test.definition

;; decl tests: `test someDecl { ... }`
(test_declaration
  .
  (identifier) @test.name) @test.definition
]]

M.root = lib.files.match_root_pattern("build.zig", "build.zig.zon", ".git")

local ignored_dirs = {
  [".git"] = true,
  [".zig-cache"] = true,
  ["zig-cache"] = true,
  ["zig-out"] = true,
  ["zig-pkg"] = true,
  ["node_modules"] = true,
}

function M.filter_dir(name)
  return not ignored_dirs[name]
end

function M.is_test_file(file_path)
  if not vim.endswith(file_path, ".zig") then
    return false
  end
  local ok, content = pcall(lib.files.read, file_path)
  if not ok then
    return false
  end
  -- Cheap text check; discover_positions does the real parse.
  return content:find("^test[%s{\"]") ~= nil or content:find("\ntest[%s{\"]") ~= nil
end

---@async
function M.discover_positions(path)
  return lib.treesitter.parse_positions(path, test_query, { nested_tests = false })
end

---------------------------------------------------------------------------
-- running
---------------------------------------------------------------------------
-- $4/$5: file + standalone template used when the project `test` step ran no
-- tests at all (e.g. the file is not reachable from it) -- then fall back to
-- per-file mode, which is what `zig test <file>` does.
local run_script = [[
log=$1; src=$2; root=$3; fallback_file=$4; fallback_src=$5; shift 5
mkdir -p "$root" || exit 1
cp "$src" "$root/]] .. wrapper_name .. [[" || exit 1
zig build test --color off --summary all --build-file "$root/]] .. wrapper_name .. [[" "$@" >"$log" 2>&1
code=$?
rm -f "$root/]] .. wrapper_name .. [["

if [ -n "$fallback_file" ] && ! grep -Eq '\([0-9]+ total\)' "$log"; then
  alt="$log.alt"
  zig build test --color off --summary all --build-file "$fallback_src" -Dneotest-file="$fallback_file" "$@" >"$alt" 2>&1
  alt_code=$?
  if grep -Eq '\([0-9]+ total\)' "$alt"; then
    mv "$alt" "$log"
    code=$alt_code
  else
    rm -f "$alt"
  fi
fi

cat "$log"
exit $code
]]

local function strip_quotes(name)
  return (name:gsub('^"(.*)"$', "%1"))
end

--- Collect filters (`.test.<name>` / `.decltest.<name>`) for every test below `tree`.
local function filters_for(tree)
  local seen, filters = {}, {}
  for _, node in tree:iter_nodes() do
    local data = node:data()
    if data.type == "test" then
      local name = strip_quotes(data.name)
      for _, kind in ipairs({ ".test.", ".decltest." }) do
        local filter = kind .. name
        if not seen[filter] then
          seen[filter] = true
          table.insert(filters, filter)
        end
      end
    end
  end
  return filters
end

---@async
---@param args neotest.RunArgs
---@return neotest.RunSpec|nil
function M.build_spec(args)
  if args.strategy == "dap" then
    vim.notify("neotest-zig-build: debugging is not supported", vim.log.levels.WARN)
    return nil
  end

  local pos = args.tree:data()
  local zig_args = {}
  local src, root, cwd

  -- vim.fs.root starts at the parent of `source`; give dirs a dummy child.
  local project_root = vim.fs.root(pos.type == "dir" and (pos.path .. "/_") or pos.path, "build.zig")

  if project_root then
    src, root, cwd = assets_dir .. "/neotest_build.zig", project_root, project_root
  elseif pos.type == "dir" then
    return nil -- loose directories: descend and run file by file
  else
    -- no build.zig anywhere above: build just this file. cwd is the file's own
    -- directory, matching `zig test <file>` (relative paths in the test resolve
    -- against it); zig's caches stay in the assets dir.
    vim.fn.mkdir(standalone_dir, "p") -- the run script copies the wrapper there
    src, root, cwd = assets_dir .. "/neotest_standalone.zig", standalone_dir, vim.fs.dirname(pos.path)
    table.insert(zig_args, "-Dneotest-file=" .. pos.path)
  end

  -- dir / project-wide runs are unfiltered; file / test runs are filtered
  local fallback_file, fallback_src = "", ""
  if pos.type == "file" or pos.type == "test" then
    local filters = filters_for(args.tree)
    for _, filter in ipairs(filters) do
      table.insert(zig_args, "-Dneotest-filter=" .. filter)
    end
    -- single file / single test: if the project `test` step runs nothing, retry
    -- this file on its own (covers files not reachable from the `test` step)
    fallback_file, fallback_src = pos.path, assets_dir .. "/neotest_standalone.zig"
  end

  local log = nio.fn.tempname()
  local command = { "sh", "-c", run_script, "neotest-zig-build", log, src, root, fallback_file, fallback_src }
  vim.list_extend(command, zig_args)

  return {
    command = command,
    cwd = cwd,
    context = { log = log, root = project_root },
  }
end

---------------------------------------------------------------------------
-- results
---------------------------------------------------------------------------
--- Parse zig build runner output (pure; unit-testable).
---@param text string
function M._parse(text)
  local parsed = { failures = {}, compile_errors = {}, passed = 0, failed = 0 }
  local current

  local function finish_block()
    if current then
      current.block = table.concat(current.lines, "\n")
      parsed.failures[current.fqn] = current
      current = nil
    end
  end

  for line in (text .. "\n"):gmatch("(.-)\r?\n") do
    local fqn, rest = line:match("^error: '(.-)' failed:?%s*(.*)$")
    local kind = "failed"
    if not fqn then
      fqn, rest = line:match("^error: '(.-)' (leaked.*)$")
      kind = "leaked"
    end

    if fqn then
      finish_block()
      current = { fqn = fqn, kind = kind, lines = { line }, message = rest ~= "" and rest or nil }
    elseif line:match("^error:") or line:match("^failed command:") or line:match("^Build Summary") then
      finish_block()
    elseif current then
      table.insert(current.lines, line)
      -- first non-blank, non-stack-frame line is the message (`expect(false)` has none)
      if line:match("%.zig:%d+:%d+: 0x") then
        current.in_trace = true
      elseif not current.message and not current.in_trace and line:match("%S") then
        current.message = vim.trim(line)
      end
    end

    local file, lnum, col, msg = line:match("^(%S+%.zig):(%d+):(%d+): error: (.+)$")
    if file then
      table.insert(parsed.compile_errors, { file = file, line = tonumber(lnum), col = tonumber(col), message = msg })
    end

    local pass = line:match("run test (%d+) pass")
    if pass then
      parsed.passed = parsed.passed + tonumber(pass)
    end
    local fail = line:match("run test .-(%d+) fail")
    if fail then
      parsed.failed = parsed.failed + tonumber(fail)
    end
  end
  finish_block()

  return parsed
end

local function same_file(candidate, path, root)
  if candidate == path then
    return true
  end
  local rel = root and path:sub(#root + 2) or vim.fn.fnamemodify(path, ":t")
  return rel ~= "" and vim.endswith(candidate, "/" .. rel)
end

local function failure_line(block, path, root)
  for file, lnum in block:gmatch("(%S+%.zig):(%d+):%d+: 0x%x+ in ") do
    if same_file(file, path, root) then
      return tonumber(lnum) - 1
    end
  end
end

-- Output styling. `neotest.output.open()` and the output panel render into
-- terminal buffers, so ANSI escapes work and inherit the colorscheme's
-- terminal palette (theme green / red / yellow) instead of hardcoding hex.
-- Icons are Nerd Font glyphs (U+F00C, U+F00D, U+F051); swap them here.
local status_style = {
  passed = { icon = "\u{f00c}", ansi = "32" },
  failed = { icon = "\u{f00d}", ansi = "31" },
  skipped = { icon = "\u{f051}", ansi = "33" },
}

local function styled(status, text)
  local style = status_style[status]
  if not style then
    return text
  end
  return "\27[" .. style.ansi .. "m" .. text .. "\27[0m"
end

--- Condense a raw `zig build` log for `neotest.output.open()`: zig's step tree,
--- timings, `MaxRSS`, `(cached|reused)` markers and the `failed command:` line
--- (a long absolute path plus `--listen=-`) are noise. Keep the test's own
--- output and any failure blocks, prefixed with a per-test summary.
---@param text string
---@param parsed table Result of `M._parse`
---@param tests? { name: string, status: string, short?: string }[] In tree order
function M._condense(text, parsed, tests)
  tests = tests or {}
  local keep = {}
  for line in (text .. "\n"):gmatch("(.-)\r?\n") do
    -- Lua patterns have no alternation, so these are separate matches
    local scaffolding = line:match("^failed command:")
      or line:match("^Build Summary:")
      or line:match("^%s*[+|]")
      or line:match("^test%s*$")
      or line:match("^test%s+success%s*$")
      or line:match("^test%s+failure%s*$")
      or line:match("^test%s+transitive failure%s*$")
    if not scaffolding then
      local blank = line:match("^%s*$") ~= nil
      if not (blank and (keep[#keep] == nil or keep[#keep] == "")) then
        table.insert(keep, blank and "" or line)
      end
    end
  end
  while keep[1] == "" do
    table.remove(keep, 1)
  end
  while keep[#keep] == "" do
    table.remove(keep)
  end

  local passed, failed, skipped = 0, 0, 0
  for _, test in ipairs(tests) do
    if test.status == "passed" then
      passed = passed + 1
    elseif test.status == "failed" then
      failed = failed + 1
    else
      skipped = skipped + 1
    end
  end
  if #tests == 0 then -- no per-test tree (e.g. a run reported before discovery)
    passed, failed = parsed.passed, parsed.failed
  end

  local header = styled("passed", "Passed: " .. passed) .. " | " .. styled("failed", "Failed: " .. failed)
  if skipped > 0 then
    header = header .. " | " .. styled("skipped", "Skipped: " .. skipped)
  end

  local out = { header }
  for _, test in ipairs(tests) do
    local status = status_style[test.status] and test.status or "skipped"
    local line = styled(status, status_style[status].icon .. " " .. test.name)
    if test.short and test.short ~= "" then
      line = line .. " — " .. test.short
    end
    table.insert(out, line)
  end
  if #keep > 0 then
    table.insert(out, "")
    vim.list_extend(out, keep)
  end
  return table.concat(out, "\n") .. "\n"
end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
function M.results(spec, result, tree)
  local ok, text = pcall(lib.files.read, spec.context.log)
  if not ok or not text then
    ok, text = pcall(lib.files.read, result.output)
  end
  text = ok and text or ""
  pcall(vim.fn.delete, spec.context.log)

  local parsed = M._parse(text)
  local results = {}
  local order = {}
  local root = spec.context.root
  local ran_something = parsed.passed + parsed.failed > 0
  local build_failed = result.code ~= 0 and next(parsed.failures) == nil

  for _, node in tree:iter_nodes() do
    local data = node:data()
    if data.type == "test" then
      local name = strip_quotes(data.name)
      local stem = vim.fn.fnamemodify(data.path, ":t:r")
      local failure = parsed.failures[stem .. ".test." .. name] or parsed.failures[stem .. ".decltest." .. name]

      if failure then
        results[data.id] = {
          status = "failed",
          short = failure.message or ("test " .. failure.kind),
          output = spec.context.log,
          errors = {
            { message = failure.message or ("test " .. failure.kind), line = failure_line(failure.block, data.path, root) },
          },
        }
      elseif build_failed and not ran_something then
        local errors = {}
        local first
        for _, err in ipairs(parsed.compile_errors) do
          first = first or err
          if same_file(err.file, data.path, root) then
            table.insert(errors, { message = err.message, line = err.line - 1 })
          end
        end
        results[data.id] = {
          status = "failed",
          short = first and first.message or "zig build failed",
          errors = errors,
        }
      elseif not ran_something then
        results[data.id] = {
          status = "skipped",
          short = "no tests ran (not reachable from the `test` step)",
        }
      else
        results[data.id] = { status = "passed" }
      end
      table.insert(order, { name = name, status = results[data.id].status, short = results[data.id].short })
    end
  end

  -- Keep a condensed view of the output around for `neotest.output.open()`.
  local output_path = nio.fn.tempname()
  pcall(lib.files.write, output_path, M._condense(text, parsed, order))
  for _, r in pairs(results) do
    r.output = output_path
  end

  return results
end

setmetatable(M, {
  __call = function()
    return M
  end,
})

return M
