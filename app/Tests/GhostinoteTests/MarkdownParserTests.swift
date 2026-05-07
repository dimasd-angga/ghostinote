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

    func testParsesThematicBreaks() {
        let dashes = MarkdownParser.parse("before\n\n---\n\nafter")
        XCTAssertEqual(dashes.count, 3)
        if case .paragraph(let p) = dashes[0] { XCTAssertEqual(p, "before") } else { XCTFail() }
        if case .rule = dashes[1] {} else { XCTFail("expected .rule, got \(dashes[1])") }
        if case .paragraph(let p) = dashes[2] { XCTAssertEqual(p, "after") } else { XCTFail() }

        let stars = MarkdownParser.parse("***")
        if case .rule = stars.first {} else { XCTFail("'***' should be a rule") }

        let underscores = MarkdownParser.parse("___")
        if case .rule = underscores.first {} else { XCTFail("'___' should be a rule") }

        let withSpaces = MarkdownParser.parse("- - -")
        if case .rule = withSpaces.first {} else { XCTFail("'- - -' should be a rule") }
    }

    func testThematicBreakDoesNotEatTableSeparator() {
        let source = """
        | A | B |
        |---|---|
        | 1 | 2 |
        """
        let blocks = MarkdownParser.parse(source)
        XCTAssertEqual(blocks.count, 1)
        if case .table = blocks[0] {} else { XCTFail("table should win over thematic break") }
    }

    func testRuleEndsParagraph() {
        let source = "first line\n---\nsecond line"
        let blocks = MarkdownParser.parse(source)
        XCTAssertEqual(blocks.count, 3)
        if case .paragraph(let p) = blocks[0] { XCTAssertEqual(p, "first line") } else { XCTFail() }
        if case .rule = blocks[1] {} else { XCTFail() }
        if case .paragraph(let p) = blocks[2] { XCTAssertEqual(p, "second line") } else { XCTFail() }
    }

    func testRejectsTwoDashesAsRule() {
        let blocks = MarkdownParser.parse("--")
        if case .paragraph = blocks.first {} else { XCTFail("two dashes is not a rule") }
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
