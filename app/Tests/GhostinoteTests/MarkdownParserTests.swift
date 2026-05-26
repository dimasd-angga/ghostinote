import XCTest
@testable import Ghostinote

final class MarkdownParserTests: XCTestCase {
    func testParsesSimpleTable() {
        let source = """
        | Name | Role |
        |------|------|
        | Ada  | Eng  |
        | Bob  | PM   |
        """
        let blocks = MarkdownParser.parse(source)
        guard case let .table(header, alignments, rows) = blocks.first else {
            return XCTFail("Expected a table block, got \(blocks)")
        }
        XCTAssertEqual(header, ["Name", "Role"])
        XCTAssertEqual(alignments, [.leading, .leading])
        XCTAssertEqual(rows, [["Ada", "Eng"], ["Bob", "PM"]])
    }

    func testParsesTableAlignmentMarkers() {
        let source = """
        | Left | Center | Right |
        |:-----|:------:|------:|
        | a    | b      | c     |
        """
        let blocks = MarkdownParser.parse(source)
        guard case let .table(_, alignments, _) = blocks.first else {
            return XCTFail("Expected a table block")
        }
        XCTAssertEqual(alignments, [.leading, .center, .trailing])
    }

    func testTableEndsAtBlankLine() {
        let source = """
        | A | B |
        |---|---|
        | 1 | 2 |

        a paragraph after
        """
        let blocks = MarkdownParser.parse(source)
        XCTAssertEqual(blocks.count, 2)
        if case let .table(_, _, rows) = blocks[0] {
            XCTAssertEqual(rows, [["1", "2"]])
        } else { XCTFail() }
        if case let .paragraph(text) = blocks[1] {
            XCTAssertEqual(text, "a paragraph after")
        } else { XCTFail() }
    }

    func testRejectsBareLineWithPipeAsTable() {
        let source = "a | b without a separator row"
        let blocks = MarkdownParser.parse(source)
        if case .paragraph = blocks.first {
            // expected
        } else {
            XCTFail("Expected a paragraph, got \(blocks)")
        }
    }

    func testParsesHeadingsListsAndTablesInSequence() {
        let source = """
        # Title

        - one
        - two

        | x | y |
        |---|---|
        | 1 | 2 |
        """
        let blocks = MarkdownParser.parse(source)
        XCTAssertEqual(blocks.count, 3)
        if case .heading(let level, let text) = blocks[0] {
            XCTAssertEqual(level, 1)
            XCTAssertEqual(text, "Title")
        } else { XCTFail() }
        if case .list(let items) = blocks[1] {
            XCTAssertEqual(items.count, 2)
        } else { XCTFail() }
        if case .table = blocks[2] {
            // ok
        } else { XCTFail() }
    }

    func testPadsShortRowsAndTrimsLongRows() {
        let source = """
        | A | B | C |
        |---|---|---|
        | 1 | 2 |
        | 1 | 2 | 3 | 4 |
        """
        let blocks = MarkdownParser.parse(source)
        guard case let .table(_, _, rows) = blocks.first else { return XCTFail() }
        XCTAssertEqual(rows[0], ["1", "2", ""])
        XCTAssertEqual(rows[1], ["1", "2", "3"])
    }
}
