# How to Install

## Prerequisite

As of now, Wevi supports Windows and MacOS (Apple silicon).

Make sure you have **Zig v0.13.0 / nightly** installed on your platform.

## Installation

Navigate to your project directory. e.g., `cd my_awesome_project`

### Install the Nightly Version

Fetch wevi as zig package dependency by running:

```sh
zig fetch --save \
https://github.com/bitlaab-bolt/wevi/archive/refs/heads/main.zip
```

### Install a Release Version

Fetch wevi as zig package dependency by running:

```sh
zig fetch --save \
https://github.com/bitlaab-bolt/wevi/archive/refs/tags/"your-version".zip
```

Add wevi as dependency to your project by coping following code on your project.

```zig title="build.zig"
const wevi = b.dependency("wevi", .{});
exe.root_module.addImport("wevi", wevi.module("wevi"));
lib.root_module.addImport("wevi", wevi.module("wevi"));
```

### Shared Library Dependency

