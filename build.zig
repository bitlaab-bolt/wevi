const std = @import("std");
const builtin = @import("builtin");


pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSafe
    });

    // Exposing as a dependency for other projects
    const pkg = b.addModule("wevi", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize
    });

    pkg.addIncludePath(b.path("libs/include"));

    // Making executable for this project
    const exe = b.addExecutable(.{
        .name = "wevi",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.addIncludePath(b.path("libs/include"));

    // Adding cross-platform dependency
    switch (target.query.os_tag orelse builtin.os.tag) {
        .windows => {
            switch (target.query.cpu_arch orelse builtin.cpu.arch) {
                .x86_64 => {
                    pkg.addObjectFile(b.path("libs/windows/webviewdll.lib"));
                    pkg.linkSystemLibrary("ole32", .{});
                    pkg.linkSystemLibrary("user32", .{});
                    pkg.linkSystemLibrary("shell32", .{});
                    pkg.linkSystemLibrary("shlwapi", .{});
                    pkg.linkSystemLibrary("version", .{});
                    pkg.linkSystemLibrary("advapi32", .{});

                    exe.addObjectFile(b.path("libs/windows/webviewdll.lib"));
                    exe.linkSystemLibrary("ole32");
                    exe.linkSystemLibrary("user32");
                    exe.linkSystemLibrary("shell32");
                    exe.linkSystemLibrary("shlwapi");
                    exe.linkSystemLibrary("version");
                    exe.linkSystemLibrary("advapi32");
                },
                else => @panic("Unsupported architecture!")
            }
        },
        .macos => {
            exe.linkLibCpp();

            switch (target.query.cpu_arch orelse builtin.cpu.arch) {
                .aarch64 => {
                    pkg.addObjectFile(b.path("libs/macOS/libwebview.a"));
                    pkg.linkFramework("WebKit", .{});

                    exe.addObjectFile(b.path("libs/macOS/libwebview.a"));
                    exe.linkFramework("WebKit");
                },
                else => @panic("Unsupported architecture!")
            }
        },
        else => @panic("Codebase is not tailored for this platform!")
    }

    // Adding External Dependency
    const jsonic = b.dependency("jsonic", .{});
    exe.root_module.addImport("jsonic", jsonic.module("jsonic"));

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&b.addRunArtifact(exe).step);
}
