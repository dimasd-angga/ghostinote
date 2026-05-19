import XCTest
@testable import Ghostinote

final class TextMatcherTests: XCTestCase {
    func testEmptyNeedleReturnsNoMatches() {
        XCTAssertTrue(TextMatcher.ranges(of: "", in: "hello").isEmpty)
    }

    func testFindsAllOccurrencesCaseInsensitively() {
        let ranges = TextMatcher.ranges(of: "abc", in: "abc def Abc xyz ABC")
        XCTAssertEqual(ranges.count, 3)
        XCTAssertEqual(ranges[0], NSRange(location: 0, length: 3))
        XCTAssertEqual(ranges[1], NSRange(location: 8, length: 3))
        XCTAssertEqual(ranges[2], NSRange(location: 16, length: 3))
    }

    func testNoMatch() {
        XCTAssertTrue(TextMatcher.ranges(of: "zzz", in: "hello world").isEmpty)
    }

    func testOverlappingNeedleAdvancesCorrectly() {
        // "aaaa" with needle "aa" — non-overlapping matches.
        let ranges = TextMatcher.ranges(of: "aa", in: "aaaa")
        XCTAssertEqual(ranges, [
            NSRange(location: 0, length: 2),
            NSRange(location: 2, length: 2),
        ])
    }

    func testHandlesUnicode() {
        let ranges = TextMatcher.ranges(of: "café", in: "I love café and CAFÉ")
        XCTAssertEqual(ranges.count, 2)
    }
}
