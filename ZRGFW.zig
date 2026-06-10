const std = @import("std");

pub const Window = opaque {};

extern fn RGFW_createWindow(title: [*:0]const u8, x: i32, y: i32, w: u32, h: u32, args: u16) ?*Window;
pub fn createWindow(title: [:0]const u8, width: u32, height: u32) ?*Window {
    return RGFW_createWindow(title.ptr, 0, 0, width, height, 0);
}

extern fn RGFW_window_close(win: *Window) void;
pub fn closeWindow(window: *Window) void {
    RGFW_window_close(window);
}

extern fn RGFW_window_shouldClose(win: *Window) bool;
pub fn windowShouldClose(win: *Window) bool {
    return RGFW_window_shouldClose(win);
}

pub const Event = opaque {};
extern fn RGFW_window_checkEvent(win: *Window, event: *Event) bool;
pub fn windowCheckEvent(win: *Window, event: *Event) bool {
    return RGFW_window_checkEvent(win, event);
}
