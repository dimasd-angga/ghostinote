import Foundation

enum MarkdownDetector {
    static func looksLikeMarkdown(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        for line in trimmed.split(separator: "\n", omittingEmptySubsequences: false) {
            let l = line.trimmingCharacters(in: .whitespaces)
            if l.hasPrefix("# ") || l.hasPrefix("## ") || l.hasPrefix("### ")
                || l.hasPrefix("#### ") || l.hasPrefix("##### ") || l.hasPrefix("###### ") {
                return true
            }
            if l.hasPrefix("- ") || l.hasPrefix("* ") || l.hasPrefix("+ ") || l.hasPrefix("> ") {
                return true
            }
            if l.hasPrefix("```") { return true }
            if l.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil { return true }
        }

        let inlinePatterns = [
            #"\*\*[^*\n]+\*\*"#,
            #"(?<!\*)\*[^*\n]+\*(?!\*)"#,
            #"`[^`\n]+`"#,
            #"\[[^\]\n]+\]\([^)\n]+\)"#,
            #"!\[[^\]\n]*\]\([^)\n]+\)"#,
            #"~~[^~\n]+~~"#,
        ]
        for pattern in inlinePatterns {
            if trimmed.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        return false
    }
}
