# API References

Make sure to checkout code comments for additional details.

## [webview](https://github.com/webview/webview)

Tiny cross-platform webview library for C/C++. Uses WebKit (GTK/Cocoa) and Edge WebView2 (Windows).

**Wevi exposes underlying `webview` APIs to `wevi.Api.webview`.**

### Create Webview Instance

`webview.create()` maps to `webview_create()` in webview.

### Destroy Webview Instance

`webview.destroy()` maps to `webview_destroy()` in webview.

### Run Main Loop

`webview.run()` maps to `webview_run()` in webview.

### Stop the Main Loop

`webview.terminate()` maps to `webview_terminate()` in webview.

### Invoke Function on Run/Event Loop

`webview.dispatch()` maps to `webview_dispatch()` in webview.

### Native Window Handle

`webview.getWindow()` maps to `webview_get_window()` in webview.

### Native Handle of Choice

`webview.getNativeHandle()` maps to `webview_get_native_handle()` in webview.

### Updates Window Title

`webview.setTitle()` maps to `webview_set_title()` in webview.

### Updates Window Size

`webview.setSize()` maps to `webview_set_size()` in webview.

### Loads HTML Content

`webview.setHtml()` maps to `webview_set_html()` in webview.

### Navigates Webview Page

`webview.navigate()` maps to `webview_navigate()` in webview.

### Evaluates Arbitrary JS Code

`webview.evalJs()` maps to `webview_eval()` in webview.

### Injects JS Code

`webview.runJs()` maps to `webview_init()` in webview.

### Binds Backend Function

`webview.bind()` maps to `webview_bind()` in webview.

### Unbinds Backend Function

`webview.unbind()` maps to `webview_unbind()` in webview.

### Backend Response to JS Code

`webview.@"return"()` maps to `webview_return()` in webview.

### Version Information

`webview.version()` maps to `webview_version()` in webview.
