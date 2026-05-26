import Foundation

struct Note: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var body: String
    var updatedAt: Date

    init(id: UUID = UUID(), title: String, body: String, updatedAt: Date = .now) {
        self.id = id
        self.title = title
        self.body = body
        self.updatedAt = updatedAt
    }

    static func deriveTitle(from body: String, fallback: String = "Untitled") -> String {
        for raw in body.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = raw.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty else { continue }
            let stripped = line.drop(while: { $0 == "#" || $0 == " " })
            let candidate = String(stripped).trimmingCharacters(in: .whitespaces)
            if candidate.isEmpty { continue }
            return candidate.count <= 32 ? candidate : String(candidate.prefix(30)) + "…"
        }
        return fallback
    }
}
