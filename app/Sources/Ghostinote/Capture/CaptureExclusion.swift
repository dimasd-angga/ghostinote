import AppKit
import CoreGraphics

enum CaptureExclusion {
    @MainActor
    static func apply(to window: NSWindow) {
        window.sharingType = .none
    }

    @MainActor
    static func setHidden(_ hidden: Bool, on window: NSWindow) {
        window.sharingType = hidden ? .none : .readOnly
    }

    @MainActor
    static func verify(window: NSWindow) -> Bool {
        let windowID = CGWindowID(window.windowNumber)
        // Uses CGWindowListCreateImage (deprecated in 14+, still works and needs
        // no screen-recording permission for our own window). Roadmap v1.0 migrates
        // verification to ScreenCaptureKit.
        let image = CGWindowListCreateImage(
            .null,
            .optionIncludingWindow,
            windowID,
            [.boundsIgnoreFraming, .nominalResolution]
        )
        return image == nil
    }
}
