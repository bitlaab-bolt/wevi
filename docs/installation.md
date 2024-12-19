# How to Install

## Prerequisite

As of now, Lime supports Windows and MacOS (Apple silicon).

Make sure you have **Zig v0.13.0 / nightly** installed on your platform.

## Installation

Navigate to your project directory. e.g., `cd my_awesome_project`

### Install the Nightly Version

Fetch lime as zig package dependency by running:

```sh
zig fetch --save \
https://github.com/bitlaab-bolt/lime/archive/refs/heads/main.zip
```

### Install a Release Version

Fetch lime as zig package dependency by running:

```sh
zig fetch --save \
https://github.com/bitlaab-bolt/lime/archive/refs/tags/"your-version".zip
```

Add lime as dependency to your project by coping following code on your project.

```zig title="build.zig"
const lime = b.dependency("lime", .{});
exe.root_module.addImport("lime", lime.module("lime"));
lib.root_module.addImport("lime", lime.module("lime"));
```
