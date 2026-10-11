# Change Log

All notable changes to this project will be documented in this file.
This project adheres to the [Semantic Version](https://semver.org/) guideline.

## [Version] - yyyy-mm-dd

Here we write upgrading notes and make them as straightforward as possible.

### Added
- A short description for added item 1
- A short description for added item 2
- A short description for added item n

### Changed
- A short description for changed item 1
- A short description for changed item 2
- A short description for changed item n

### Fixed
- A short description for fixed item 1
- A short description for fixed item 2
- A short description for fixed item n


## [v1.0.0] - 2026-10-11

Initial stable release of the high-level `Wevi` API with direct access to the
underlying webview C API bindings.

### Changed
- `Wevi.create()` now reports failure as an error (e.g. when the WebView2
  runtime is missing on Windows) instead of silently returning a null-backed
  instance.
- `getNativeHandle()` now takes a typed `NativeHandleKind` enum
  (`.UiWindow`, `.UiWidget`, `.BrowserController`) instead of a raw `u32`.
- Error sets tightened: `Wevi.title()` and the low-level `setTitle()` now
  return the documented `Error` set instead of `anyerror`.
- Window size hints unified into a single code path for all platforms.
- Error-code conversion de-duplicated behind a single internal check.

## [v0.6.0] - 2026-01-29

Updating underlying `jsonic` package version.

## [v0.5.0] - 2025-04-15

Supports both Windows (x64) and MacOS (Apple Silicon).
