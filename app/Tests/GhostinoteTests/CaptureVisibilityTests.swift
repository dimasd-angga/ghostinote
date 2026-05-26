import XCTest
@testable import Ghostinote

@MainActor
final class CaptureVisibilityTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suite = "ghostinote-visibility-tests"

    override func setUp() async throws {
        defaults = UserDefaults(suiteName: suite)
        defaults.removePersistentDomain(forName: suite)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suite)
    }

    func testDefaultsToHidden() {
        let v = CaptureVisibility(defaults: defaults)
        XCTAssertTrue(v.isHidden)
    }

    func testTogglePersistsAcrossInstances() {
        let first = CaptureVisibility(defaults: defaults)
        first.toggle()
        XCTAssertFalse(first.isHidden)

        let second = CaptureVisibility(defaults: defaults)
        XCTAssertFalse(second.isHidden)

        second.toggle()
        let third = CaptureVisibility(defaults: defaults)
        XCTAssertTrue(third.isHidden)
    }

    func testIdempotentWrites() {
        let v = CaptureVisibility(defaults: defaults)
        v.isHidden = true
        v.isHidden = true
        XCTAssertTrue(v.isHidden)
    }
}
