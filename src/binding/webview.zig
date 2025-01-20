const std = @import("std");
const builtin = @import("builtin");

const webview = @cImport({ @cInclude("webview.h"); });


pub const Error = error {
    /// Operation canceled
    Canceled,
    /// Something already exists
    Duplicate,
    /// Invalid state detected
    InvalidState,
    /// One or more invalid arguments have been specified
    /// - e.g. In a function call
    InvalidArgument,
    /// Missing dependency
    MissingDependency,
    /// Something does not exist
    NotFound,
    /// An unspecified error occurred
    Unspecified
};

pub const Window = ?*anyopaque;

pub const Anything = ?*anyopaque;

pub const Inspect = enum(i32) { Off = 0, On = 1 };

pub const Version = struct { major: u8, minor: u8, patch: u8 };

pub const Callback = ?*const fn(Window, Anything) callconv(.c) void;

pub const BindCallback = ?*const fn([*c]const u8, [*c]const u8, Anything) callconv(.c) void;

pub fn create(debug: Inspect, win: Anything) Error!Window {
    const debug_mode = @intFromEnum(debug);
    return webview.webview_create(debug_mode, win);
}

pub fn destroy(win: Window) Error!void {
    const rv = webview.webview_destroy(win);
    if (rv != 0) return @"error"(rv);
}

pub fn run(win: Window) Error!void {
    const rv = webview.webview_run(win);
    if (rv != 0) return @"error"(rv);
}

pub fn terminate(win: Window) Error!void {
    const rv = webview.webview_terminate(win);
    if (rv != 0) return @"error"(rv);
}

pub fn dispatch(win: Window, cbf: Callback, arg: Anything) Error!void {
    const rv = webview.webview_dispatch(win, cbf, arg);
    if (rv != 0) return @"error"(rv);
}

pub fn getWindow(win: Window) Window {
    return webview.webview_get_window(win);
}

pub fn getNativeHandle(win: Window, kind: u32) Window {
    return webview.webview_get_native_handle(win, kind);
}

pub fn setTitle(win: Window, txt: []const u8) Error!void {
    const rv = webview.webview_set_title(win, txt.ptr);
    if (rv != 0) return @"error"(rv);
}

/// # Window Size Hints
pub const Hint = enum(u32) {
  /// Width and height are default size
  None = 0,
  /// Width and height are minimum bounds
  Minimum = 1,
  /// Width and height are maximum bounds
  Maximum = 2,
  /// Window size can not be changed by a user
  Fixed = 3
};

pub fn setSize(win: Window, width: u16, height: u16, hint: Hint) Error!void {
    switch (builtin.os.tag) {
        .windows => {
            const w_hint: c_int = @intCast(@intFromEnum(hint));
            const rv = webview.webview_set_size(win, width, height, w_hint);
            if (rv != 0) return @"error"(rv);
        },
        .macos => {
            const w_hint = @intFromEnum(hint);
            const rv = webview.webview_set_size(win, width, height, w_hint);
            if (rv != 0) return @"error"(rv);
        },
        else => unreachable
    }
}

pub fn setHtml(win: Window, content: []const u8) Error!void {
    const rv = webview.webview_set_html(win, content.ptr);
    if (rv != 0) return @"error"(rv);
}

pub fn navigate(win: Window, url: []const u8) Error!void {
    const rv = webview.webview_navigate(win, url.ptr);
    if (rv != 0) return @"error"(rv);
}


pub fn evalJs(win: Window, script: []const u8) Error!void {
    const rv = webview.webview_eval(win, script.ptr);
    if (rv != 0) return @"error"(rv);
}

pub fn runJs(win: Window, script: []const u8) Error!void {
    const rv = webview.webview_init(win, script.ptr);
    if (rv != 0) return @"error"(rv);
}

pub fn bind(
    win: Window,
    name: []const u8,
    cbf: BindCallback,
    arg: Anything
) Error!void {
    const rv = webview.webview_bind(win, name.ptr, cbf, arg);
    if (rv != 0) return @"error"(rv);
}

pub fn unbind(win: Window, name: []const u8) Error!void {
    const rv = webview.webview_unbind(win, name.ptr);
    if (rv != 0) return @"error"(rv);
}

pub fn @"return"(
    win: Window,
    id: []const u8,
    status: i32,
    result: []const u8
) Error!void {
    const rv = webview.webview_return(win, id.ptr, status, result.ptr);
    if (rv != 0) return @"error"(rv);
}

pub fn version() Version {
    const info = webview.webview_version();
    return .{
        .major = @as(u8, @intCast(info.*.version.major)),
        .minor = @as(u8, @intCast(info.*.version.minor)),
        .patch = @as(u8, @intCast(info.*.version.patch))
    };
}

/// # Converts Error Messages
fn @"error"(code: i32) Error!void {
    return switch (code) {
         1 => Error.Duplicate,
         2 => Error.NotFound,
        -1 => Error.Unspecified,
        -2 => Error.InvalidArgument,
        -3 => Error.InvalidState,
        -4 => Error.Canceled,
        -5 => Error.MissingDependency,
        else => unreachable
    };
}
