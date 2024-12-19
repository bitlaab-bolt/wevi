# How to use

First import Lime on your zig file.

```zig
const lime = @import("lime");
```

## PNG Module

### Load RAW Image Pixels

```zig
var gpa_mem = std.heap.GeneralPurposeAllocator(.{}){};
defer std.debug.assert(gpa_mem.deinit() == .ok);
const heap = gpa_mem.allocator();

// Replace "./flash.png" with your targeted image path
const image = try lime.Png.loadImage(heap, "./flash.png");
defer lime.Png.freeImage(heap, image.data);

switch(image) {
    .err => |v| {
        std.debug.print("Error: {s}\n", .{v});
        return error.FailedToLoad;
    },
    .data => |v| {
        // `v` Contains Raw pixel data
        std.debug.print("Total pixels {d}\n", .{v.len});
    },
    .ihdr => unreachable
}
```

### Load Image Header Info

```zig
// Replace "./flash.png" with your targeted image path
const ihdr = try lime.Png.loadImageHeader("./flash.png");
switch(image) {
    .err => |v| {
        std.debug.print("Error: {s}\n", .{v});
        return error.FailedToLoad;
    },
    .ihdr => |v| {
        // `v` Contains IHDR data
        std.debug.print("Info: {any}\n", .{v});
    },
    .data => unreachable
}
```