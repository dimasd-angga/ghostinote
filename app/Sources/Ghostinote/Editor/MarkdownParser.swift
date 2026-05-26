import Foundation

enum MarkdownBlock: Equatable {
    case heading(level: Int, text: String)
    case paragraph(String)
    case quote(String)
    case code(String)
    case list(items: [ListItem])
    case table(header: [String], alignments: [TableAlignment], rows: [[String]])

    struct ListItem: Equatable {
        let ordered: Bool
        let text: String
    }
}

enum TableAlignment: Equatable {
    case leading, center, trailing
}

enum MarkdownParser {
    static func parse(_ source: String) -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        let lines = source.components(separatedBy: "\n")
        var i = 0

        while i < lines.count {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("```") {
                var code: [String] = []
                i += 1
                while i < lines.count, !lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    code.append(lines[i])
                    i += 1
                }
                blocks.append(.code(code.joined(separator: "\n")))
                i += 1
                continue
            }

            if let level = headingLevel(trimmed) {
                let content = String(trimmed.drop(while: { $0 == "#" })).trimmingCharacters(in: .whitespaces)
                blocks.append(.heading(level: level, text: content))
                i += 1
                continue
            }

            if isTableHeader(at: i, in: lines) {
                let (table, consumed) = parseTable(startingAt: i, in: lines)
                blocks.append(table)
                i += consumed
                continue
            }

            if trimmed.hasPrefix("> ") {
                var quote: [String] = []
                while i < lines.count,
                      lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("> ") {
                    quote.append(String(lines[i].trimmingCharacters(in: .whitespaces).dropFirst(2)))
                    i += 1
                }
                blocks.append(.quote(quote.joined(separator: "\n")))
                continue
            }

            if isListItem(trimmed) {
                var items: [MarkdownBlock.ListItem] = []
                while i < lines.count {
                    let l = lines[i].trimmingCharacters(in: .whitespaces)
                    if l.hasPrefix("- ") || l.hasPrefix("* ") || l.hasPrefix("+ ") {
                        items.append(.init(ordered: false, text: String(l.dropFirst(2))))
                    } else if let match = l.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                        items.append(.init(ordered: true, text: String(l[match.upperBound...])))
                    } else {
                        break
                    }
                    i += 1
                }
                blocks.append(.list(items: items))
                continue
            }

            if trimmed.isEmpty {
                i += 1
                continue
            }

            var paragraph: [String] = [line]
            i += 1
            while i < lines.count {
                let next = lines[i].trimmingCharacters(in: .whitespaces)
                if next.isEmpty || headingLevel(next) != nil || next.hasPrefix("```")
                    || next.hasPrefix("> ") || isListItem(next)
                    || isTableHeader(at: i, in: lines) {
                    break
                }
                paragraph.append(lines[i])
                i += 1
            }
            blocks.append(.paragraph(paragraph.joined(separator: " ")))
        }

        return blocks
    }

    // MARK: - Heading

    static func headingLevel(_ s: String) -> Int? {
        var count = 0
        for ch in s {
            if ch == "#" { count += 1 } else { break }
        }
        guard count >= 1, count <= 6 else { return nil }
        let rest = s.dropFirst(count)
        guard rest.first == " " else { return nil }
        return count
    }

    // MARK: - List

    static func isListItem(_ s: String) -> Bool {
        s.hasPrefix("- ") || s.hasPrefix("* ") || s.hasPrefix("+ ")
            || s.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil
    }

    // MARK: - Table

    static func isTableHeader(at index: Int, in lines: [String]) -> Bool {
        guard index + 1 < lines.count else { return false }
        let header = lines[index].trimmingCharacters(in: .whitespaces)
        let separator = lines[index + 1].trimmingCharacters(in: .whitespaces)
        guard header.contains("|"), separator.contains("|") else { return false }
        let cells = splitRow(separator)
        guard !cells.isEmpty else { return false }
        for cell in cells {
            let trimmed = cell.trimmingCharacters(in: .whitespaces)
            let pattern = #"^:?-{3,}:?$"#
            if trimmed.range(of: pattern, options: .regularExpression) == nil {
                return false
            }
        }
        let headerCells = splitRow(header)
        return headerCells.count == cells.count
    }

    static func parseTable(startingAt index: Int, in lines: [String]) -> (MarkdownBlock, Int) {
        let header = splitRow(lines[index])
        let alignments = splitRow(lines[index + 1]).map { parseAlignment($0) }
        var rows: [[String]] = []
        var i = index + 2
        while i < lines.count {
            let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || !trimmed.contains("|") { break }
            var cells = splitRow(lines[i])
            while cells.count < header.count { cells.append("") }
            if cells.count > header.count { cells = Array(cells.prefix(header.count)) }
            rows.append(cells)
            i += 1
        }
        return (.table(header: header, alignments: alignments, rows: rows), i - index)
    }

    private static func splitRow(_ row: String) -> [String] {
        var trimmed = row.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("|") { trimmed.removeFirst() }
        if trimmed.hasSuffix("|") { trimmed.removeLast() }
        return trimmed
            .split(separator: "|", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }

    private static func parseAlignment(_ s: String) -> TableAlignment {
        let t = s.trimmingCharacters(in: .whitespaces)
        let left = t.hasPrefix(":")
        let right = t.hasSuffix(":")
        switch (left, right) {
        case (true, true): return .center
        case (false, true): return .trailing
        default: return .leading
        }
    }
}
