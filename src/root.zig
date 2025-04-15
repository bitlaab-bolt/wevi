//! # Webview Library Binding
//! - See documentation at - https://bitlaabwevi.web.app/

pub const Wevi = @import("./core/wevi.zig");


/// # API Bindings for Underlying Libraries
pub const Api = struct {
    pub const webview = @import("./binding/webview.zig");
};
