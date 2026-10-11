const webview = @import("webview");

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
    // The underlying C API reports creation failure only via a null return
    // (e.g. missing WebView2 runtime on Windows), so map it to an error here.
    return webview.webview_create(debug_mode, win) orelse Error.Unspecified;
}

pub fn destroy(win: Window) Error!void {
    try check(webview.webview_destroy(win));
}

pub fn run(win: Window) Error!void {
    try check(webview.webview_run(win));
}

pub fn terminate(win: Window) Error!void {
    try check(webview.webview_terminate(win));
}

pub fn dispatch(win: Window, cbf: Callback, arg: Anything) Error!void {
    try check(webview.webview_dispatch(win, cbf, arg));
}

pub fn getWindow(win: Window) Window {
    return webview.webview_get_window(win);
}

pub fn getNativeHandle(win: Window, kind: NativeHandleKind) Window {
    return webview.webview_get_native_handle(win, @intFromEnum(kind));
}

pub fn setTitle(win: Window, name: [:0]const u8) Error!void {
    try check(webview.webview_set_title(win, name));
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

/// # Native Handle Kind
pub const NativeHandleKind = enum(u32) {
  /// Top-level window e.g., NSWindow pointer (macOS), HWND (Windows)
  UiWindow = 0,
  /// Browser widget e.g., NSView pointer (macOS), HWND (Windows)
  UiWidget = 1,
  /// Browser controller e.g., WKWebView pointer (macOS), ICoreWebView2Controller pointer (Windows)
  BrowserController = 2
};

pub fn setSize(win: Window, width: u16, height: u16, hint: Hint) Error!void {
    const w_hint: c_uint = @intCast(@intFromEnum(hint));
    try check(webview.webview_set_size(win, width, height, w_hint));
}

pub fn setHtml(win: Window, content: [:0]const u8) Error!void {
    try check(webview.webview_set_html(win, content));
}

pub fn navigate(win: Window, url: [:0]const u8) Error!void {
    try check(webview.webview_navigate(win, url));
}


pub fn evalJs(win: Window, script: [:0]const u8) Error!void {
    try check(webview.webview_eval(win, script));
}

pub fn runJs(win: Window, script: [:0]const u8) Error!void {
    try check(webview.webview_init(win, script));
}

pub fn bind(
    win: Window,
    name: [:0]const u8,
    cbf: BindCallback,
    arg: Anything
) Error!void {
    try check(webview.webview_bind(win, name, cbf, arg));
}

pub fn unbind(win: Window, name: [:0]const u8) Error!void {
    try check(webview.webview_unbind(win, name));
}

pub fn @"return"(
    win: Window,
    id: [:0]const u8,
    status: i32,
    result: [:0]const u8
) Error!void {
    try check(webview.webview_return(win, id, status, result));
}

pub fn version() Version {
    const info = webview.webview_version();
    return .{
        .major = @intCast(info.*.version.major),
        .minor = @intCast(info.*.version.minor),
        .patch = @intCast(info.*.version.patch)
    };
}

/// # Checks a C API Result and Maps it to an Error
fn check(rv: i32) Error!void {
    if (rv != 0) return @"error"(rv);
}

/// # Converts Error Codes
fn @"error"(code: i32) Error {
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
