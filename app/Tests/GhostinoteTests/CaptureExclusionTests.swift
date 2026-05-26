import XCTest
import AppKit
@testable import Ghostinote

final class CaptureExclusionTests: XCTestCase {
    @MainActor
    func testApplySetsSharingTypeToNone() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        XCTAssertEqual(window.sharingType, .readOnly)

        CaptureExclusion.apply(to: window)

        XCTAssertEqual(window.sharingType, .none)
    }
}
