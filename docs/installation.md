# How to Install

Navigate to your project directory. e.g., `cd my_awesome_project`

### Install the Nightly Version

Fetch **wevi** as external package dependency by running:

```sh
zig fetch --save \
https://github.com/bitlaab-bolt/wevi/archive/refs/heads/main.zip
```

### Install a Release Version

Fetch **wevi** as external package dependency by running:

```sh
zig fetch --save \
https://github.com/bitlaab-bolt/wevi/archive/refs/tags/v0.0.0.zip
```

Make sure to edit `v0.0.0` with the latest release version.

## Import Module

Now, import **wevi** as external package module to your project by coping following code:

```zig title="build.zig"
const wevi = b.dependency("wevi", .{});
exe.root_module.addImport("wevi", wevi.module("wevi"));
lib.root_module.addImport("wevi", wevi.module("wevi"));
```

### Shared Library Dependency

When you're targeting the Windows platform:

For nightly version download [webview.dll](https://github.com/bitlaab-bolt/wevi/blob/main/libs/windows/webview.dll) and put this in your final executable's installation directory.

For the release version, download `webview.dll` from the attachment section of the Release Tag.
