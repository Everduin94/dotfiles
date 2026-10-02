// Wrapper build file used by lua/neotest-zig-build.
//
// It is copied next to a project's build.zig for the duration of one run and
// invoked as `zig build test --build-file .neotest_build.zig -Dneotest-filter=...`.
// It runs the project's own `build()` untouched, then applies `-Dneotest-filter`
// to every test compile step reachable from the requested top-level step, so
// the project's modules, imports and dependencies all keep working.
//
// It also marks every test *run* step as having side effects, so the test
// binaries re-execute even when nothing changed. A cached run step prints no
// test counts at all, and the adapter needs those counts to tell a pass apart
// from "the filter matched nothing" (e.g. a file not reachable from `test`).
// Compile steps stay cached, so repeat runs are still fast.
const std = @import("std");
const user = @import("build.zig");

const Step = std.Build.Step;

fn compileStep(step: *Step) ?*Step.Compile {
    if (comptime @hasDecl(Step, "cast")) return Step.cast(step, Step.Compile);
    if (comptime @hasField(Step, "id")) {
        if (step.id == .compile) return @fieldParentPtr("step", step);
    }
    return null;
}

fn runStep(step: *Step) ?*Step.Run {
    if (comptime @hasDecl(Step, "cast")) return Step.cast(step, Step.Run);
    if (comptime @hasField(Step, "id")) {
        if (step.id == .run) return @fieldParentPtr("step", step);
    }
    return null;
}

fn walk(
    b: *std.Build,
    step: *Step,
    filters: ?[]const []const u8,
    seen: *std.AutoHashMap(*Step, void),
) void {
    if ((seen.getOrPut(step) catch return).found_existing) return;

    if (compileStep(step)) |compile| {
        if (filters) |f| {
            if (compile.kind == .@"test") compile.filters = b.dupeStrings(f);
        }
    } else if (runStep(step)) |run| {
        if (comptime @hasField(Step.Run, "producer")) {
            if (run.producer) |producer| {
                if (producer.kind == .@"test") run.has_side_effects = true;
            }
        }
    }

    for (step.dependencies.items) |dep| walk(b, dep, filters, seen);
}

pub fn build(b: *std.Build) !void {
    const result = user.build(b);
    if (@typeInfo(@TypeOf(result)) == .error_union) try result;

    const step_name = b.option([]const u8, "neotest-step", "neotest: top-level step to filter") orelse "test";
    const top = b.top_level_steps.get(step_name) orelse return;
    const filters = b.option([]const []const u8, "neotest-filter", "neotest: test name filter(s)");

    var seen = std.AutoHashMap(*Step, void).init(b.allocator);
    walk(b, &top.step, filters, &seen);
}
