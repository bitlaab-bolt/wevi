const std = @import("std");

const webview = @cImport({
    @cInclude("webview.h");
});


pub const Error = error {
    /// Operation canceled
    CANCELED,
    /// Something already exists
    DUPLICATE,
    /// Invalid state detected
    INVALID_STATE,
    /// One or more invalid arguments have been specified
    /// - e.g. In a function call
    INVALID_ARGUMENT,
    /// Missing dependency
    MISSING_DEPENDENCY,
    /// Something does not exist
    NOT_FOUND,
    /// An unspecified error occurred
    UNSPECIFIED,
};

pub const Version = struct { major: u8, minor: u8, patch: u8 };

pub const Window = ?*anyopaque;

pub const Anything = ?*anyopaque;
pub const Callback = ?*const fn(Window, Anything) callconv(.c) void;

pub const Inspect = enum(i32) { Off = 0, On = 1 };

pub fn create(debug: Inspect, win: Anything) Error!Window {
    const debug_mode = @intFromEnum(debug);

    // 2nd argument is an optional native window handle
    // e.g., GtkWindow pointer, NSWindow pointer etc.
    return webview.webview_create(debug_mode, win);

    // TODO
    // handle error
}

pub fn destroy(win: Window) Error!void {
    const rv = webview.webview_destroy(win);
    if (rv != 0) return err(rv);
}

pub fn run(win: Window) Error!void {
    const rv = webview.webview_run(win);
    if (rv != 0) return err(rv);
}

pub fn terminate(win: Window) Error!void {
    const rv = webview.webview_terminate(win);
    if (rv != 0) return err(rv);
}

/// no needed when using glfw
pub fn dispatch(win: Window, cbf: Callback, arg: Anything) Error!void {
    const rv = webview.webview_dispatch(win, cbf, arg);
    if (rv != 0) return err(rv);
}

// why this is useful?
pub fn getWindow(win: Window) Window {
    return webview.webview_get_window(win);
}


pub fn getNativeHandle() void {
    // TODO
}

pub fn setTitle(win: Window, txt: []const u8) Error!void {
    const rv = webview.webview_set_title(win, txt.ptr);
    if (rv != 0) return err(rv);
}


/// Window Size Hints
pub const Hint = enum(u32) {
  /// Width and height are default size
  NONE = 0,
  /// Width and height are minimum bounds
  MINIMUM = 1,
  /// Width and height are maximum bounds
  MAXIMUM = 2,
  /// Window size can not be changed by a user
  FIXED = 3
};

pub fn setSize(win: Window, width: u16, height: u16, hint: Hint) Error!void {
    const rv = webview.webview_set_size(win, width, height, @intFromEnum(hint));
    if (rv != 0) return err(rv);
}

/// what kind of urls are supported
pub fn navigate(win: Window, url: []const u8) Error!void {
    const rv = webview.webview_navigate(win, url.ptr);
    if (rv != 0) return err(rv);
}

pub fn setHtml(win: Window, content: []const u8) Error!void {
    const rv = webview.webview_set_html(win, content.ptr);
    if (rv != 0) return err(rv);
}

pub fn runJs(win: Window, script: []const u8) Error!void {
    const rv = webview.webview_init(win, script.ptr);
    if (rv != 0) return err(rv);
}

pub fn evalJs(win: Window, script: []const u8) Error!void {
    const rv = webview.webview_eval(win, script.ptr);
    if (rv != 0) return err(rv);
}


pub const BindCallback = ?*const fn([*c]const u8, [*c]const u8, Anything) callconv(.c) void;

pub fn bind(
    win: Window,
    name: []const u8,
    cbf: BindCallback,
    arg: Anything
) Error!void {
    const rv = webview.webview_bind(win, name.ptr, cbf, arg);
    if (rv != 0) return err(rv);
}

pub fn unbind(win: Window, name: []const u8,) Error!void {
    const rv = webview.webview_unbind(win, name.ptr);
    if (rv != 0) return err(rv);
}

pub fn @"return"(
    win: Window,
    bind_id: []const u8,
    status: i32,
    result: []const u8
) !void {
    const rv = webview.webview_return(win, bind_id.ptr, status, result.ptr);
    if (rv != 0) return err(rv);
}

pub fn version() Version {
    const info = webview.webview_version();
    return .{
        .major = @as(u8, @intCast(info.*.version.major)),
        .minor = @as(u8, @intCast(info.*.version.minor)),
        .patch = @as(u8, @intCast(info.*.version.patch))
    };
}

fn err(code: i32) Error!void {
    return switch (code) {
        1 => Error.DUPLICATE,
        2 => Error.NOT_FOUND,
        -1 => Error.UNSPECIFIED,
        -2 => Error.INVALID_ARGUMENT,
        -3 => Error.INVALID_STATE,
        -4 => Error.CANCELED,
        -5 => Error.MISSING_DEPENDENCY,
        else => unreachable
    };
}