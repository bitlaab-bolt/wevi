const webview = @import("../binding/webview.zig");


window: webview.Window,

const Self = @This();

pub fn create(debug: webview.Inspect, win: ?*anyopaque) !Self {
    return .{.window = try webview.create(debug, win) };
}

pub fn destroy(self: *Self) !void {
    try webview.destroy(self.window);
}

pub fn run(self: *Self) !void {
    try webview.run(self.window);
}

/// # Stops the Main Loop
/// - It is safe to call this function from a background thread.
pub fn terminate(self: *Self) !void {
    try webview.terminate(self.window);
}

pub fn dispatch(self: *Self, cbf: webview.Callback, arg: webview.Anything) !void {
    try webview.dispatch(self.window, cbf, arg);
}


pub fn title(self: *Self, txt: []const u8) !void {
    try webview.setTitle(self.window, txt);
}

pub fn size(self: *Self, width: u16, height: u16, hint: webview.Hint) !void {
    try webview.setSize(self.window, width, height, hint);
}

pub fn navigate(self: *Self, url: []const u8) !void {
    try webview.navigate(self.window, url);
}

pub fn setHtml(self: *Self, content: []const u8) !void {
    try webview.setHtml(self.window, content);
}

pub fn runJs(self: *Self, script: []const u8) !void {
    try webview.runJs(self.window, script);
}

pub fn evalJs(self: *Self, script: []const u8) !void {
    try webview.evalJs(self.window, script);
}

pub fn version() webview.Version {
    return webview.version();
}