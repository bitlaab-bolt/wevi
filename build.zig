const std = @import("std");
const builtin = @import("builtin");


pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // C header translation (replaces the @cImport block)
    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("libs/include/webview.h"),
        .target = target,
        .optimize = optimize
    });
    translate_c.addIncludePath(b.path("libs/include"));

    // Exposing as a dependency for other projects
    const pkg = b.addModule("wevi", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize
    });

    pkg.addIncludePath(b.path("libs/include"));

    pkg.addImport("webview", translate_c.createModule());

    const main = b.addModule("main", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    main.addIncludePath(b.path("libs/include"));

    const app = "wevi";
    const exe = b.addExecutable(.{.name = app, .root_module = main});

    // Adding cross-platform dependency (module link objects propagate to
    // every artifact that imports this module, so they are only set here)
    switch (target.query.os_tag orelse builtin.os.tag) {
        .macos => {
            exe.root_module.link_libcpp = true;

            switch (target.query.cpu_arch orelse builtin.cpu.arch) {
                .aarch64 => {
                    pkg.addObjectFile(b.path("libs/macOS/libwebview.a"));
                    pkg.linkFramework("WebKit", .{});
                },
                else => @panic("Unsupported architecture!")
            }
        },
        .windows => {
            switch (target.query.cpu_arch orelse builtin.cpu.arch) {
                .x86_64 => {
                    pkg.addObjectFile(
                        b.path("libs/windows/webviewdll.lib")
                    );
                    pkg.linkSystemLibrary("ole32", .{});
                    pkg.linkSystemLibrary("user32", .{});
                    pkg.linkSystemLibrary("shell32", .{});
                    pkg.linkSystemLibrary("shlwapi", .{});
                    pkg.linkSystemLibrary("version", .{});
                    pkg.linkSystemLibrary("advapi32", .{});
                },
                else => @panic("Unsupported architecture!")
            }
        },
        else => @panic("Codebase is not tailored for this platform!")
    }

    // Self importing package
    exe.root_module.addImport("wevi", pkg);

    // Adding External Dependency
    const jsonic = b.dependency("jsonic", .{});
    exe.root_module.addImport("jsonic", jsonic.module("jsonic"));

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Unit tests for the wevi module
    const lib_tests = b.addTest(.{.root_module = pkg});
    const run_lib_tests = b.addRunArtifact(lib_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_tests.step);
}
