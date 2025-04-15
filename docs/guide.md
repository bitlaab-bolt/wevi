# Developer Guide

If you are using previous release of Jsonic for some reason, you can generate documentation for that release by following these steps:

- Install [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/getting-started/) on your platform.

- Download and extract `Source code (zip)` for your target release at [**Jsonic Repo**](https://github.com/bitlaab-bolt/jsonic)

- Now, `cd` into your release directory and run: `mkdocs serve`

## Generate Code Documentation

To generate Zig's API documentation, navigate to your project directory and run:

```sh
zig build-lib -femit-docs=docs/zig-docs src/root.zig
```

Now, clean up any unwanted generated file and make sure to link `zig-docs/index.html` to your `reference.md` file.

## Building `webview` from Source (Windows)

**Remarks:** Always use **MSVC** tool chain on windows for consistency.

Make sure to build the source code via LLVM's `clang` compiler since Zig also uses `clang`. When compiling for the first time (on a freshly installed Windows), make sure to add necessary binaries from Visual Studio Build Tools to system environment variables.

### Watchout 01

As of version **webview v0.12.0** ninja fails to build due to the following code section where multiple rules is generated for the same name. Make sure to update the `STATIC_LIBRARY_OUTPUT_NAME` on `core/CMakeLists.txt`.

```cmake
# Core static library
if(WEBVIEW_BUILD_STATIC_LIBRARY)
    # Change .lib file name for MSVC because otherwise it would be the same for shared and static
    if(MSVC)
        set(STATIC_LIBRARY_OUTPUT_NAME webview_static)
    else()
        set(STATIC_LIBRARY_OUTPUT_NAME webview)
        # Change `webview` to something else e.g., webview_my_custom_name
    endif()

    add_library(webview_core_static STATIC)
    add_library(webview::core_static ALIAS webview_core_static)
    target_sources(webview_core_static PRIVATE src/webview.cc)
    target_link_libraries(webview_core_static PUBLIC webview_core_headers)
    set_target_properties(webview_core_static PROPERTIES
        OUTPUT_NAME "${STATIC_LIBRARY_OUTPUT_NAME}"
        POSITION_INDEPENDENT_CODE ON
        EXPORT_NAME core_static)
    target_compile_definitions(webview_core_static PUBLIC WEBVIEW_STATIC)
endif()
```

### Watchout 02

Do not forgot to change the `--config` name to **Release** when compiling.

```sh
cmake -G "Ninja Multi-Config" -B build -S .
cmake --build build --config Release
```

### Watchout 03

For some reasons linking static library always fails due to `stdc++` issues in both **MSVC** and **MinGW-w64** build system. But generated shared library on **MSVC** works. So, make sure to add `webview.dll` on windows for the final binary for the wevi dependency on a real world project. You will find the necessary steps in the **Installation** section in this doc.
