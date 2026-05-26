import Foundation

struct NoteStore {
    let directory: URL

    static func defaultLocation() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Ghostinote", isDirectory: true)
            .appendingPathComponent("notes", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base
    }

    init(directory: URL = NoteStore.defaultLocation()) {
        self.directory = directory
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func loadAll() -> [Note] {
        let urls = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.contentModificationDateKey])) ?? []
        let notes: [Note] = urls.compactMap { url in
            guard url.pathExtension == "md" else { return nil }
            guard let id = UUID(uuidString: url.deletingPathExtension().lastPathComponent) else { return nil }
            guard let raw = try? String(contentsOf: url, encoding: .utf8) else { return nil }
            let (title, body) = Self.split(raw)
            let modified = (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .now
            return Note(id: id, title: title, body: body, updatedAt: modified)
        }
        return notes.sorted { $0.updatedAt > $1.updatedAt }
    }

    func save(_ note: Note) throws {
        let url = directory.appendingPathComponent("\(note.id.uuidString).md")
        let payload = Self.join(title: note.title, body: note.body)
        try payload.data(using: .utf8)?.write(to: url, options: .atomic)
    }

    func delete(id: UUID) throws {
        let url = directory.appendingPathComponent("\(id.uuidString).md")
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - serialization

    private static let titleMarker = "<!-- ghostinote:title "
    private static let titleEnd = " -->\n"

    static func split(_ raw: String) -> (title: String, body: String) {
        guard raw.hasPrefix(titleMarker) else {
            return (Note.deriveTitle(from: raw), raw)
        }
        guard let endRange = raw.range(of: titleEnd) else {
            return (Note.deriveTitle(from: raw), raw)
        }
        let titleStart = raw.index(raw.startIndex, offsetBy: titleMarker.count)
        let title = String(raw[titleStart..<endRange.lowerBound])
        let body = String(raw[endRange.upperBound...])
        return (title, body)
    }

    static func join(title: String, body: String) -> String {
        let safeTitle = title
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "-->", with: "→")
        return titleMarker + safeTitle + titleEnd + body
    }
}
