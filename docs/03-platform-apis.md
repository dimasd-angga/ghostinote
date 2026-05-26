# Platform API — macOS Capture Exclusion (Swift)

This is the entire mechanism. One property, set on the `NSWindow`.

## Apply

```swift
// app/Sources/Ghostinote/Capture/CaptureExclusion.swift
import AppKit

enum CaptureExclusion {
    /// Excludes `window` from CGWindowList*, CGDisplayStream, ScreenCaptureKit,
    /// AVCaptureScreenInput, and any app that screen-captures via these APIs
    /// (Zoom, Meet, Teams, OBS, QuickTime, browser getDisplayMedia, etc.).
    ///
    /// MUST be called before `window.makeKeyAndOrderFront(_:)` so the window
    /// is never captured even momentarily.
    static func apply(to window: NSWindow) {
        window.sharingType = .none
    }
}
```

Usage:

```swift
let window = OverlayWindow(contentRect: …, …)
CaptureExclusion.apply(to: window)
window.makeKeyAndOrderFront(nil)
```

## Verify (v1.0 trust panel)

Self-test by capturing our own window region and confirming we are absent:

```swift
import CoreGraphics

extension CaptureExclusion {
    /// Returns true if the window is correctly excluded from CGWindowList capture.
    /// Run this in the background after launch as a sanity check.
    @MainActor
    static func verify(window: NSWindow) -> Bool {
        let windowID = CGWindowID(window.windowNumber)
        // Ask CG to give us an image of *only* this window. If exclusion works,
        // we get a nil / empty image back.
        let image = CGWindowListCreateImage(
            .null,
            .optionIncludingWindow,
            windowID,
            [.boundsIgnoreFraming, .nominalResolution]
        )
        return image == nil
    }
}
```

If `verify` returns `false`, the trust panel turns red and tells the user — never silently degrade.

For a stricter check we can also run a tiny `ScreenCaptureKit` `SCStream` against the main display and confirm our window is not in `SCShareableContent.current.windows` for capture purposes. Overkill for v0; nice for v1.0.

## App entitlements

None required for `sharingType = .none`. It's an in-process property of our own window. No screen-recording permission, no accessibility permission.

(Screen-recording permission would only be needed for the *self-test* in v1.0 — and only if we use ScreenCaptureKit for verification. The `CGWindowListCreateImage` self-test does **not** need that permission for capturing our own window on macOS 14+.)

## Related window properties worth knowing

- `window.collectionBehavior.insert(.canJoinAllSpaces)` — overlay follows the user across Spaces.
- `window.collectionBehavior.insert(.fullScreenAuxiliary)` — overlay can appear over another app's fullscreen window (essential during presentations).
- `window.level = .floating` — above normal windows. `.statusBar` if you need to go above almost everything.
- `window.ignoresMouseEvents = true` — click-through mode (v0.5).

All AppKit, all documented, no private APIs.
