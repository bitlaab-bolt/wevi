const std = @import("std");

const wevi = @import("./core/wevi.zig");

pub fn main() !void {
    var wevi_win = try wevi.create(.Off, null);

    try wevi_win.title("hello world!");
    try wevi_win.setHtml("<h1>Hello world</h1>");
    // try wevi_win.navigate("http://example.com");
    try wevi_win.evalJs("console.log('hello world')");
    try wevi_win.size(720, 480, .NONE);

    try wevi_win.run();
    try wevi_win.destroy();
}
