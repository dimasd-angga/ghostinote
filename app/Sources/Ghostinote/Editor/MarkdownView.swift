import SwiftUI

struct MarkdownView: View {
    let source: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                    block.view
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
    }

    private var blocks: [RenderedBlock] {
        MarkdownParser.parse(source)
    }
}

private struct RenderedBlock: Identifiable {
    let id = UUID()
    let view: AnyView
}

private enum MarkdownParser {
    static func parse(_ source: String) -> [RenderedBlock] {
        var blocks: [RenderedBlock] = []
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
                blocks.append(codeBlock(code.joined(separator: "\n")))
                i += 1
                continue
            }

            if let heading = headingLevel(trimmed) {
                let content = String(trimmed.drop(while: { $0 == "#" })).trimmingCharacters(in: .whitespaces)
                blocks.append(headingBlock(content, level: heading))
                i += 1
                continue
            }

            if trimmed.hasPrefix("> ") {
                var quote: [String] = []
                while i < lines.count,
                      lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("> ") {
                    quote.append(String(lines[i].trimmingCharacters(in: .whitespaces).dropFirst(2)))
                    i += 1
                }
                blocks.append(quoteBlock(quote.joined(separator: "\n")))
                continue
            }

            if isListItem(trimmed) {
                var items: [(ordered: Bool, text: String)] = []
                while i < lines.count {
                    let l = lines[i].trimmingCharacters(in: .whitespaces)
                    if l.hasPrefix("- ") || l.hasPrefix("* ") || l.hasPrefix("+ ") {
                        items.append((false, String(l.dropFirst(2))))
                    } else if let match = l.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                        items.append((true, String(l[match.upperBound...])))
                    } else {
                        break
                    }
                    i += 1
                }
                blocks.append(listBlock(items))
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
                    || next.hasPrefix("> ") || isListItem(next) {
                    break
                }
                paragraph.append(lines[i])
                i += 1
            }
            blocks.append(paragraphBlock(paragraph.joined(separator: " ")))
        }

        return blocks
    }

    private static func headingLevel(_ s: String) -> Int? {
        var count = 0
        for ch in s {
            if ch == "#" { count += 1 } else { break }
        }
        guard count >= 1, count <= 6 else { return nil }
        let rest = s.dropFirst(count)
        guard rest.first == " " else { return nil }
        return count
    }

    private static func isListItem(_ s: String) -> Bool {
        s.hasPrefix("- ") || s.hasPrefix("* ") || s.hasPrefix("+ ")
            || s.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil
    }

    private static func headingBlock(_ text: String, level: Int) -> RenderedBlock {
        let font: Font
        switch level {
        case 1: font = .system(size: 22, weight: .bold)
        case 2: font = .system(size: 18, weight: .bold)
        case 3: font = .system(size: 16, weight: .semibold)
        default: font = .system(size: 14, weight: .semibold)
        }
        return RenderedBlock(view: AnyView(
            inlineText(text)
                .font(font)
                .padding(.top, level <= 2 ? 6 : 2)
        ))
    }

    private static func paragraphBlock(_ text: String) -> RenderedBlock {
        RenderedBlock(view: AnyView(inlineText(text).font(.body)))
    }

    private static func quoteBlock(_ text: String) -> RenderedBlock {
        RenderedBlock(view: AnyView(
            HStack(alignment: .top, spacing: 8) {
                Rectangle().fill(Color.secondary.opacity(0.5)).frame(width: 3)
                inlineText(text).foregroundStyle(.secondary).italic()
            }
            .padding(.vertical, 2)
        ))
    }

    private static func codeBlock(_ code: String) -> RenderedBlock {
        RenderedBlock(view: AnyView(
            Text(code)
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.black.opacity(0.25))
                .cornerRadius(6)
        ))
    }

    private static func listBlock(_ items: [(ordered: Bool, text: String)]) -> RenderedBlock {
        RenderedBlock(view: AnyView(
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(item.ordered ? "\(idx + 1)." : "•")
                            .foregroundStyle(.secondary)
                            .frame(width: 16, alignment: .trailing)
                        inlineText(item.text)
                    }
                }
            }
        ))
    }

    private static func inlineText(_ raw: String) -> Text {
        if let attributed = try? AttributedString(
            markdown: raw,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            return Text(attributed)
        }
        return Text(raw)
    }
}
