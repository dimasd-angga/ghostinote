import AppKit
import CoreGraphics

enum CaptureExclusion {
    @MainActor
    static func apply(to window: NSWindow) {
        window.sharingType = .none
    }

    @MainActor
    static func verify(window: NSWindow) -> Bool {
        let windowID = CGWindowID(window.windowNumber)
        let image = CGWindowListCreateImage(
            .null,
            .optionIncludingWindow,
            windowID,
            [.boundsIgnoreFraming, .nominalResolution]
        )
        return image == nil
    }
}
