// Wrapper build file used by lua/neotest-zig-build.
//
// It is copied next to a project's build.zig for the duration of one run and
// invoked as `zig build test --build-file .neotest_build.zig -Dneotest-filter=...`.
// It runs the project's own `build()` untouched, then applies `-Dneotest-filter`
// to every test compile step reachable from the requested top-level step, so
// the project's modules, imports and dependencies all keep working.
const std = @import("std");
const user = @import("build.zig");

fn applyFilters(
    b: *std.Build,
    step: *std.Build.Step,
    filters: []const []const u8,
    seen: *std.AutoHashMap(*std.Build.Step, void),
) void {
    if ((seen.getOrPut(step) catch return).found_existing) return;
    if (step.id == .compile) {
        const compile: *std.Build.Step.Compile = @fieldParentPtr("step", step);
        if (compile.kind == .@"test") compile.filters = b.dupeStrings(filters);
    }
    for (step.dependencies.items) |dep| applyFilters(b, dep, filters, seen);
}

pub fn build(b: *std.Build) !void {
    const result = user.build(b);
    if (@typeInfo(@TypeOf(result)) == .error_union) try result;

    const filters = b.option([]const []const u8, "neotest-filter", "neotest: test name filter(s)") orelse return;
    const step_name = b.option([]const u8, "neotest-step", "neotest: top-level step to filter") orelse "test";
    const top = b.top_level_steps.get(step_name) orelse return;

    var seen = std.AutoHashMap(*std.Build.Step, void).init(b.allocator);
    applyFilters(b, &top.step, filters, &seen);
}
