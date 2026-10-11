const std = @import("std");

const jsonic = @import("jsonic");
const Wevi = @import("wevi").Wevi;


const StrC = [*c]const u8;

/// # Context Passed to the Bind Callback
const CallbackArgs = struct {
    heap: std.mem.Allocator,
    view: *Wevi
};

/// # Handles the `greet` Call from the JavaScript Side
fn greet(id: StrC, req: StrC, arg: ?*anyopaque) callconv(.c) void {
    const args: *CallbackArgs = @ptrCast(@alignCast(arg));

    std.debug.print("greet id: {s}\n", .{std.mem.span(id)});
    std.debug.print("greet req: {s}\n", .{std.mem.span(req)});

    // Parses the JSON array of arguments passed from the JavaScript side
    var dyn_json = jsonic.DynamicJSON.init(
        args.heap, std.mem.span(req), .{}
    ) catch |err| {
        std.debug.print("Error: {any}\n", .{err});
        return;
    };
    defer dyn_json.deinit();

    const items = dyn_json.data().array.items;
    if (items.len > 0) {
        std.debug.print("First argument: {s}\n", .{items[0].string});
    }

    // Responds back to the JavaScript side (JSON stringified result)
    args.view.response(
        std.mem.span(id), 0, "[\"Hello from Wevi!\"]"
    ) catch |err| {
        std.debug.print("Error: {any}\n", .{err});
        return;
    };
}

const page =
    \\<!DOCTYPE html>
    \\<html>
    \\<head><meta charset="UTF-8"><title>Wevi Demo</title></head>
    \\<body>
    \\  <h1>Hello from Wevi!</h1>
    \\  <button id="btn">Call greet()</button>
    \\  <script>
    \\    document.getElementById('btn').addEventListener('click', async () => {
    \\      try {
    \\        const res = await window.greet('john', 23);
    \\        console.log(res);
    \\      } catch (e) { console.error(e); }
    \\    });
    \\  </script>
    \\</body>
    \\</html>
;

pub fn main() !void {
    std.debug.print("webview library v{d}.{d}.{d}\n", .{
        Wevi.version().major,
        Wevi.version().minor,
        Wevi.version().patch,
    });

    var gpa_mem = std.heap.DebugAllocator(.{}){};
    defer std.debug.assert(gpa_mem.deinit() == .ok);
    const heap = gpa_mem.allocator();

    var wevi_win = try Wevi.create(.On, null);

    try wevi_win.title("Wevi Demo");
    try wevi_win.setHtml(page);
    try wevi_win.size(720, 480, .None);

    var args = CallbackArgs { .heap = heap, .view = &wevi_win };
    try wevi_win.bind("greet", greet, @ptrCast(&args));

    try wevi_win.run();
    try wevi_win.destroy();
}
