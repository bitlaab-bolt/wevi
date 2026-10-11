# How to use

First, import Wevi into your Zig source file.

```zig
const wevi = @import("wevi");
const Wevi = wevi.Wevi;
```

Then, import Jsonic into your Zig source file (used below to parse bind
arguments in the callback).

```zig
const jsonic = @import("jsonic");
```

Then, define the callback structure.

```zig
const CallbackArgs = struct { heap: std.mem.Allocator, view: *Wevi };
```

## Create a Window

```zig
var gpa_mem = std.heap.DebugAllocator(.{}){};
defer std.debug.assert(gpa_mem.deinit() == .ok);
const heap = gpa_mem.allocator();

var wevi_win = try Wevi.create(.On, null);
try wevi_win.title("Hello World!");

// Page Loading
const cwd = try std.fs.cwd().realpathAlloc(heap, ".");
defer heap.free(cwd);

const path = "tests/index.html";
const abs_path = try std.fmt.allocPrintZ(
    heap, "file://{s}/{s}", .{cwd, path}
);
defer heap.free(abs_path);

try wevi_win.navigate(abs_path);
try wevi_win.size(720, 480, .None);

var args = CallbackArgs { .heap = heap, .view = &wevi_win };
try wevi_win.bind("greet", greet, @ptrCast(&args));

try wevi_win.run();
try wevi_win.destroy();
```

**Remarks:**
- `create(.On, null)` enables developer tools where supported and lets Wevi
  create and manage its own window. Pass a native window handle instead
  (e.g. `NSWindow` on macOS, `HWND` on Windows) to embed the webview into
  your own window — in that case you drive the application loop yourself.
- Instead of `navigate()`, HTML content can be loaded directly with
  `try wevi_win.setHtml(page)` where `page` is a null-terminated string
  (e.g. a multi-line string literal).

### Bind Callback Function

```zig
const StrC = [*c]const u8;

fn greet(id: StrC, req: StrC, args: ?*anyopaque) callconv(.c) void {
    std.debug.print("ID {s}\n", .{std.mem.span(id)});
    std.debug.print("REQ {s}\n", .{std.mem.span(req)});

    const parm: *CallbackArgs = @ptrCast(@alignCast(args));

    // `req` is a JSON array of the arguments passed from the JavaScript side
    var dyn_json = jsonic.DynamicJSON.init(
        parm.heap, std.mem.span(req), .{}
    ) catch |err| {
        std.debug.print("Error: {any}\n", .{err});
        return;
    };
    defer dyn_json.deinit();

    const json_data = dyn_json.data().array;
    const item = json_data.items[0].string;
    std.debug.print("Array Item: {s}\n", .{item});

    // Responds back to the JavaScript side - `result` must be JSON or an
    // empty string (for JS `undefined`); a non-zero status signals an error
    parm.view.response(std.mem.span(id), 0, "[\"hello world!\"]") catch |err| {
        std.debug.print("Error: {any}\n", .{err});
        return;
    };
}
```

## API Overview

All fallible functions return the `Error` set:
`Canceled`, `Duplicate`, `InvalidState`, `InvalidArgument`,
`MissingDependency`, `NotFound`, `Unspecified`.

| Function | Description |
|---|---|
| `create(debug: Inspect, win: ?*anyopaque) Error!Wevi` | Creates a new webview instance. `debug` is `.On` or `.Off`. `win` is an optional native window handle to embed into. |
| `destroy(self: *Wevi) Error!void` | Destroys the webview instance and closes the native window. |
| `run(self: *Wevi) Error!void` | Runs the main loop until terminated. Only needed when `create()` was called with `null`. |
| `terminate(self: *Wevi) Error!void` | Stops the main loop (thread safe). |
| `dispatch(self: *Wevi, cbf: Callback, arg: Anything) Error!void` | Schedules a function to be invoked on the run/event loop thread. |
| `getNativeWindow(self: *Wevi) Window` | Returns the native handle of the associated window. |
| `getNativeHandle(self: *Wevi, kind: NativeHandleKind) Window` | Returns a native handle of choice. |
| `title(self: *Wevi, txt: StrZ) Error!void` | Updates the title of the native window. |
| `size(self: *Wevi, width: u16, height: u16, hint: Hint) Error!void` | Updates the size of the native window. |
| `setHtml(self: *Wevi, content: StrZ) Error!void` | Loads HTML content into the webview. Content must be null-terminated. |
| `navigate(self: *Wevi, url: StrZ) Error!void` | Navigates to the given URL (http and file schemes). |
| `evalJs(self: *Wevi, script: StrZ) Error!void` | Evaluates arbitrary JavaScript code. **WARNING:** WebKit doesn't allow arbitrary JavaScript execution on macOS. |
| `runJs(self: *Wevi, script: StrZ) Error!void` | Injects JavaScript code to be executed upon loading a page. |
| `bind(self: *Wevi, name: StrZ, cbf: BindCallback, arg: Anything) Error!void` | Binds a function to a new global JavaScript function. |
| `unbind(self: *Wevi, name: StrZ) Error!void` | Removes a given binding. |
| `response(self: *Wevi, bind_id: StrZ, status_code: i32, result: StrZ) Error!void` | Responds to a binding call from the JavaScript side. |
| `version() Version` | Current webview version information (static call). |

A complete runnable example lives in [`src/main.zig`](../src/main.zig).

### Supporting Types

- `Inspect` - `.Off` (0) or `.On` (1), enables developer tools where supported.
- `Hint` - window size hints: `.None`, `.Minimum`, `.Maximum`, `.Fixed`.
- `NativeHandleKind` - `getNativeHandle()` kinds: `.UiWindow` (e.g. `NSWindow`
  pointer on macOS, `HWND` on Windows), `.UiWidget` (e.g. `NSView`, `HWND`)
  and `.BrowserController` (e.g. `WKWebView`, `ICoreWebView2Controller`).
- `Callback` - `fn(Window, Anything) callconv(.c) void`, used with `dispatch()`.
- `BindCallback` - `fn([*c]const u8, [*c]const u8, Anything) callconv(.c) void`,
  used with `bind()`; receives the binding call `id` and a JSON array `req`.

### Low-Level Bindings

The underlying webview C API is also exposed directly for custom control:

```zig
const webview = wevi.Api.webview;

const win = try webview.create(1, null);
defer webview.destroy(win) catch {};

try webview.setTitle(win, "Low Level");
try webview.navigate(win, "https://github.com/webview/webview");
try webview.run(win);
```

## Setup HTML Page

Create a **test** directory in your project and put this `index.html` inside
it (only needed when navigating to a local file instead of using `setHtml`).

```html title="index.html"
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

Copy `webview.dll` next to the executable (see the **Installation** section),
then:

```sh
zig build -Dtarget=x86_64-windows-msvc && \
./zig-out/bin/<your_app_name>.exe
```
