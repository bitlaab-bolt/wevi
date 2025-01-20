# How to use

First import Wevi on your zig file.

```zig
const wevi = @import("wevi").Wevi;
```

Add the following dependency.

```zig
// See documentation at - https://bitlaabjsonic.web.app/
const jsonic = @import("jsonic");
```

Now, define the following struct in global scope outside `main()`.

```zig
const CallbackArgs = struct {
    heap: std.mem.Allocator,
    view: *wevi
};
```

## Create a Window

```zig
var gpa_mem = std.heap.GeneralPurposeAllocator(.{}){};
defer std.debug.assert(gpa_mem.deinit() == .ok);
const heap = gpa_mem.allocator();

var wevi_win = try wevi.create(.On, null);
try wevi_win.title("Hello World!");

// Page Loading
const cwd = try std.fs.cwd().realpathAlloc(heap, ".");
defer heap.free(cwd);

// Change to your file path
const path = "tests/index.html";
const abs_path = try std.fmt.allocPrintZ(
    heap, "file://{s}/{s}", .{cwd, path}
);
defer heap.free(abs_path);

try wevi_win.navigate(abs_path);
try wevi_win.size(720, 480, .None);

var args = CallbackArgs { .heap = heap, .view = &wevi_win };
try wevi_win.bind("greet", greet, @ptrCast(@constCast(&args)));

try wevi_win.run();
try wevi_win.destroy();
```

### Bind Callback Function

```zig
const Info = struct { name: []const u8, age: u8 };

fn greet(
    id: [*c]const u8,
    req: [*c]const u8,
    args: ?*anyopaque
) callconv(.c) void {
    std.debug.print("ID {s}\n", .{id});
    std.debug.print("REQ {s}\n", .{req});

    const slice = std.mem.span(req);
    const parm: *CallbackArgs = @ptrCast(@alignCast(args));

    var dyn_json = jsonic.DynamicJson.init(parm.heap, slice, .{}) catch |err| {
        std.debug.print("Error: {any}\n", .{err});
        return;
    };
    defer dyn_json.deinit();

    const json_data = dyn_json.data().array;
    const item = json_data.items[0].string;
    std.debug.print("Array Item: {s}\n", .{item});

    const data: *i64 = @ptrCast(@alignCast(args));
    std.debug.print("ARGS {d}\n", .{data.*});

    parm.view.response(std.mem.span(id), 0, "[\"hello world!\"]") catch |err| {
        std.debug.print("Error: {any}\n", .{err});
        return;
    };
}
```
## Setup HTML Page

```html title="app.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Document</title>
</head>
<body>
    <h1>Hello world!</h1>
    <button id="btn">Click</button>
    <script>
        document.getElementById('btn').addEventListener('click', async () => {
            try {
                const res = await window.greet('john', 23);
                console.log(res);
            } catch (error) {
                console.error('Error occurred:', error);
            }
        })
    </script>
</body>
</html>
```

## Build and Run the Project

### Build on MacOs

```sh
zig build && \
./zig-out/bin/<your_app_name>
```

### On Windows

```sh
zig build -Dtarget=x86_64-windows-msvc && \
./zig-out/bin/<your_app_name>.exe
```
