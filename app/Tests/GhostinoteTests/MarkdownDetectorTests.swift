import XCTest
@testable import Ghostinote

final class MarkdownDetectorTests: XCTestCase {
    func testDetectsHeadings() {
        XCTAssertTrue(MarkdownDetector.looksLikeMarkdown("# Title\nbody"))
        XCTAssertTrue(MarkdownDetector.looksLikeMarkdown("### Smaller"))
    }

    func testDetectsLists() {
        XCTAssertTrue(MarkdownDetector.looksLikeMarkdown("- one\n- two"))
        XCTAssertTrue(MarkdownDetector.looksLikeMarkdown("1. first\n2. second"))
    }

    func testDetectsInlineMarkers() {
        XCTAssertTrue(MarkdownDetector.looksLikeMarkdown("hello **world**"))
        XCTAssertTrue(MarkdownDetector.looksLikeMarkdown("see `code`"))
        XCTAssertTrue(MarkdownDetector.looksLikeMarkdown("[link](https://example.com)"))
    }

    func testDetectsCodeFence() {
        XCTAssertTrue(MarkdownDetector.looksLikeMarkdown("```\nlet x = 1\n```"))
    }

    func testRejectsPlainText() {
        XCTAssertFalse(MarkdownDetector.looksLikeMarkdown("just a normal sentence."))
        XCTAssertFalse(MarkdownDetector.looksLikeMarkdown(""))
        XCTAssertFalse(MarkdownDetector.looksLikeMarkdown("nothing here\nplain stuff"))
    }

    func testDoesNotMisreadDashInWords() {
        XCTAssertFalse(MarkdownDetector.looksLikeMarkdown("non-blocking call"))
    }
}
