const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const opengl = b.option(bool, "opengl", "enables opengl") orelse false;
    const wayland = b.option(bool, "wayland", "enables wayland") orelse false;
    const vulkan = b.option(bool, "vulkan", "enables vulkan") orelse false;

    //const cRGFW = b.addTranslateC(.{
    //    .link_libc = true,
    //    .target = target,
    //    .optimize = optimize,
    //    .root_source_file = b.path("RGFW.h"),
    //});
    const cRGFW = b.addModule("RGFW", .{
        .root_source_file = b.path("ZRGFW.zig"),
        .target = target,
        .optimize = optimize,
    });
    cRGFW.link_libc = true;
    cRGFW.addIncludePath(b.path("."));
    if (wayland) cRGFW.addIncludePath(b.path("xdg"));

    cRGFW.addCMacro("RGFW_IMPLEMENTATION", "");
    if (opengl) cRGFW.addCMacro("RGFW_OPENGL", "");
    if (wayland) cRGFW.addCMacro("RGFW_WAYLAND", "");
    if (vulkan) cRGFW.addCMacro("RGFW_VULKAN", "");

    //const mod = cRGFW.addModule("RGFW");
    cRGFW.addCSourceFile(.{
        .file = b.path("RGFW.c"),
        // We pass the macros to the C compiler so it builds correctly
        .flags = &.{},
    });

    switch (target.result.os.tag) {
        .linux, .freebsd, .openbsd, .dragonfly => {
            if (opengl) cRGFW.linkSystemLibrary("GL", .{ .needed = true });
            if (vulkan) cRGFW.linkSystemLibrary("vulkan", .{ .needed = true });
            if (wayland) {
                if (opengl) {
                    cRGFW.linkSystemLibrary("EGL", .{ .needed = true });
                    cRGFW.linkSystemLibrary("wayland-egl", .{ .needed = true });
                }
                cRGFW.addCSourceFiles(.{ .files = &.{
                    "xdg/xdg-shell.c",
                    "xdg/xdg-toplevel-icon-v1.c",
                    "xdg/xdg-output-unstable-v1.c",
                    "xdg/xdg-decoration-unstable-v1.c",
                    "xdg/relative-pointer-unstable-v1.c",
                    "xdg/pointer-constraints-unstable-v1.c",
                } });
                cRGFW.addIncludePath(b.path("xdg"));
                cRGFW.linkSystemLibrary("wayland-client", .{ .needed = true });
                cRGFW.linkSystemLibrary("wayland-cursor", .{ .needed = true });
                cRGFW.linkSystemLibrary("xkbcommon", .{ .needed = true });
            } else {
                cRGFW.linkSystemLibrary("x11", .{ .needed = true });
                cRGFW.linkSystemLibrary("xrandr", .{ .needed = true });
            }
        },
        .macos => {
            cRGFW.linkFramework("CoreVideo", .{ .needed = true });
            cRGFW.linkFramework("Cocoa", .{ .needed = true });
            cRGFW.linkFramework("IOKit", .{ .needed = true });
            if (opengl) cRGFW.linkFramework("OpenGL", .{ .needed = true });
        },
        .windows => {
            cRGFW.linkSystemLibrary("gdi32", .{ .needed = true });
            if (opengl) cRGFW.linkSystemLibrary("opengl32", .{ .needed = true });
        },
        else => {},
    }
}
