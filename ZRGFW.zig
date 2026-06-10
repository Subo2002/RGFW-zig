const std = @import("std");

// 1. Manually define the opaque types or structs matching the C side
pub const Window = opaque {};

// 2. Declare the external C functions using the 'extern' keyword
// Zig automatically matches these to the compiled C symbols at link time
extern fn RGFW_createWindow(title: [*:0]const u8, x: i32, y: i32, w: u32, h: u32, args: u16) ?*Window;

extern fn RGFW_window_close(win: *Window) void;

// 3. Create your clean Zig API wrapper around the extern functions
pub fn createWindow(title: [:0]const u8, width: u32, height: u32) ?*Window {
    // We convert Zig's [:0]const u8 slice to a sentinel-terminated many-item pointer ([*:0]const u8)
    return RGFW_createWindow(title.ptr, 0, 0, width, height, 0);
}

pub fn closeWindow(window: *Window) void {
    RGFW_window_close(window);
}
