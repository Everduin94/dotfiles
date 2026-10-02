// Synthetic build.zig for .zig files that live outside any build.zig project.
// Used by lua/neotest-zig-build as `-Dneotest-file=<abs path>`.
const std = @import("std");

pub fn build(b: *std.Build) void {
    const file = b.option([]const u8, "neotest-file", "neotest: file to test") orelse return;
    const filters = b.option([]const []const u8, "neotest-filter", "neotest: test name filter(s)") orelse &.{};
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = .{ .cwd_relative = file },
            .target = target,
            .optimize = optimize,
        }),
        .filters = b.dupeStrings(filters),
    });
    b.step("test", "Run tests").dependOn(&b.addRunArtifact(tests).step);
}
