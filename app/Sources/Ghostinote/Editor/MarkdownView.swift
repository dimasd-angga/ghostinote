import SwiftUI

struct MarkdownView: View {
    let blocks: [MarkdownBlock]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                    renderBlock(block)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private func renderBlock(_ block: MarkdownBlock) -> some View {
        switch block {
        case let .heading(level, text):
            heading(text, level: level)
        case let .paragraph(text):
            inlineText(text).font(.body)
        case let .quote(text):
            HStack(alignment: .top, spacing: 8) {
                Rectangle().fill(Color.secondary.opacity(0.5)).frame(width: 3)
                inlineText(text).foregroundStyle(.secondary).italic()
            }
            .padding(.vertical, 2)
        case let .code(code):
            Text(code)
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color(nsColor: .textBackgroundColor).opacity(0.5))
                .cornerRadius(6)
        case let .list(items):
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
        case let .table(header, alignments, rows):
            tableView(header: header, alignments: alignments, rows: rows)
        case .rule:
            Divider()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
    }

    private func heading(_ text: String, level: Int) -> some View {
        inlineText(text)
            .font(headingFont(for: level))
            .padding(.top, level <= 2 ? 6 : 2)
    }

    private func headingFont(for level: Int) -> Font {
        switch level {
        case 1: return .system(size: 22, weight: .bold)
        case 2: return .system(size: 18, weight: .bold)
        case 3: return .system(size: 16, weight: .semibold)
        default: return .system(size: 14, weight: .semibold)
        }
    }

    private func tableView(header: [String], alignments: [TableAlignment], rows: [[String]]) -> some View {
        let columnCount = header.count
        let normalizedAlignments: [TableAlignment] = (0..<columnCount).map { i in
            i < alignments.count ? alignments[i] : .leading
        }

        return VStack(alignment: .leading, spacing: 0) {
            tableRow(header, alignments: normalizedAlignments, isHeader: true)
            Divider().opacity(0.6)
            ForEach(Array(rows.enumerated()), id: \.offset) { idx, row in
                tableRow(row, alignments: normalizedAlignments, isHeader: false)
                if idx < rows.count - 1 {
                    Divider().opacity(0.2)
                }
            }
        }
        .padding(8)
        .background(Color(nsColor: .textBackgroundColor).opacity(0.3))
        .cornerRadius(6)
    }

    @ViewBuilder
    private func tableRow(_ cells: [String], alignments: [TableAlignment], isHeader: Bool) -> some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(cells.enumerated()), id: \.offset) { i, cell in
                let alignment = i < alignments.count ? alignments[i] : .leading
                cellText(cell, isHeader: isHeader)
                    .frame(maxWidth: .infinity, alignment: swiftUIAlignment(alignment))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
            }
        }
    }

    @ViewBuilder
    private func cellText(_ text: String, isHeader: Bool) -> some View {
        if isHeader {
            inlineText(text).font(.system(.callout, design: .default).weight(.semibold))
        } else {
            inlineText(text).font(.callout)
        }
    }

    private func swiftUIAlignment(_ a: TableAlignment) -> Alignment {
        switch a {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }

    private func inlineText(_ raw: String) -> Text {
        if let attributed = try? AttributedString(
            markdown: raw,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            return Text(attributed)
        }
        return Text(raw)
    }
}
