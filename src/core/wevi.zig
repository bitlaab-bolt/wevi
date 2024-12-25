const webview = @import("../binding/webview.zig");
const Error = webview.Error;


window: webview.Window,

const Self = @This();

/// # Creates a New Webview Instance
/// - `win` - Native window handle e.g., GtkWindow, NSWindow, HWND etc.
pub fn create(debug: webview.Inspect, win: ?*anyopaque) Error!Self {
    return .{.window = try webview.create(debug, win) };
}

/// # Destroys a Webview Instance and Closes the Native Window
pub fn destroy(self: *Self) Error!void {
    try webview.destroy(self.window);
}

/// # Runs the Main Loop
/// **Note:** Should be ignored when `create()` is called with a native window
pub fn run(self: *Self) Error!void {
    try webview.run(self.window);
}

/// # Stops the Main Loop (Thread Safe)
/// **Note:** Should be ignored when `create()` is called with a native window
pub fn terminate(self: *Self) Error!void {
    try webview.terminate(self.window);
}

/// # Schedules a Function to be Invoked on the Run/Event Loop
/// **Note:** Should be ignored when `create()` is called with a native window
pub fn dispatch(
    self: *Self,
    cbf: webview.Callback,
    arg: webview.Anything
) Error!void {
    try webview.dispatch(self.window, cbf, arg);
}

/// # Native Handle of the Associated Window
/// **Note:** Should be ignored when `create()` is called with a native window
pub fn getNativeWindow(self: *Self) Error!webview.Window {
    return try webview.getWindow(self.window);
}

/// # Get a Native Handle of Choice
/// **Note:** Should be ignored when `create()` is called with a native window
pub fn getNativeHandle(self: *Self, kind: u32) Error!webview.Window {
    return try webview.getNativeHandle(self.window, kind);
}

/// # Updates the Title of the Native Window
/// **Note:** Should be ignored when `create()` is called with a native window
pub fn title(self: *Self, txt: []const u8) Error!void {
    try webview.setTitle(self.window, txt);
}

// # Updates the Size of the Native Window
/// **Note:** Should be ignored when `create()` is called with a native window
pub fn size(
    self: *Self,
    width: u16,
    height: u16,
    hint: webview.Hint
) Error!void {
    try webview.setSize(self.window, width, height, hint);
}

/// # Loads HTML Content into the Webview
/// - Only useful for test purposes
pub fn setHtml(self: *Self, content: []const u8) Error!void {
    try webview.setHtml(self.window, content);
}

/// # Navigates Webview to the Given URL
/// - Supports Http and File URI scheme
pub fn navigate(self: *Self, url: []const u8) Error!void {
    try webview.navigate(self.window, url);
}

/// # Evaluates Arbitrary JS Code
/// **WARNING:** Doesn't work on macOs
pub fn evalJs(self: *Self, script: []const u8) Error!void {
    try webview.evalJs(self.window, script);
}

/// # Injects JS Code to be Executed Upon Loading Page
pub fn runJs(self: *Self, script: []const u8) Error!void {
    try webview.runJs(self.window, script);
}

/// # Binds a Function to a New Global JS Function
/// - `name` - Function name in JS side
pub fn bind(
    self: *Self,
    name: []const u8,
    cbf: webview.BindCallback,
    arg: webview.Anything
) Error!void {
    try webview.bind(self.window, name, cbf, arg);
}

/// # Removes a Binding
pub fn unbind(self: *Self, name: []const u8,) Error!void {
    try webview.unbind(self.window, name);
}

/// # Responds to a Binding Call from the JS Side
/// - `id` - Binding ID from the `BindCallback` function
/// - `status` - **0** means succeed! any other value indicates an error
/// - `result` - Must be JSON stringified string
pub fn response(
    self: *Self,
    bind_id: []const u8,
    status_code: i32,
    result: []const u8
) Error!void {
    try webview.@"return"(self.window, bind_id, status_code, result);
}

/// # Current Webview Version Information
pub fn version() webview.Version {
    return webview.version();
}
