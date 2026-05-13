import Foundation
import Observation

enum ViewMode { case edit, preview }

@MainActor
@Observable
final class NotesViewModel {
    private(set) var notes: [Note]
    var selectedID: UUID
    private var modes: [UUID: ViewMode] = [:]
    private var markdownFlags: [UUID: Bool] = [:]
    private var parsedCache: [UUID: [MarkdownBlock]] = [:]
    private var snippetCache: [UUID: String] = [:]

    private let store: NoteStore
    private var saveTasks: [UUID: Task<Void, Never>] = [:]
    private var orderSaveTask: Task<Void, Never>?

    init(store: NoteStore = NoteStore()) {
        self.store = store
        let loaded = store.loadAll()
        if loaded.isEmpty {
            let seed = Note(
                title: "Ghostinote",
                body: """
                # Ghostinote

                This window is **invisible** during screen share.

                - Type your notes here
                - Drag a row to reorder
                - Right-click for rename / duplicate / delete
                """
            )
            self.notes = [seed]
            self.selectedID = seed.id
            try? store.save(seed)
        } else {
            let savedOrder = store.loadOrder()
            let ordered = Self.applyOrder(savedOrder, to: loaded)
            self.notes = ordered
            self.selectedID = ordered.first!.id
        }
        for note in notes {
            markdownFlags[note.id] = MarkdownDetector.looksLikeMarkdown(note.body)
            parsedCache[note.id] = MarkdownParser.parse(note.body)
            snippetCache[note.id] = Self.makeSnippet(note.body)
        }
    }

    private static func applyOrder(_ order: [UUID], to notes: [Note]) -> [Note] {
        guard !order.isEmpty else { return notes }
        var byID = Dictionary(uniqueKeysWithValues: notes.map { ($0.id, $0) })
        var result: [Note] = []
        for id in order {
            if let n = byID.removeValue(forKey: id) { result.append(n) }
        }
        result.append(contentsOf: byID.values.sorted { $0.updatedAt > $1.updatedAt })
        return result
    }

    var selected: Note {
        notes.first(where: { $0.id == selectedID }) ?? notes[0]
    }

    func body(of id: UUID) -> String {
        notes.first(where: { $0.id == id })?.body ?? ""
    }

    func snippet(of id: UUID) -> String {
        snippetCache[id] ?? ""
    }

    func parsedBlocks(of id: UUID) -> [MarkdownBlock] {
        parsedCache[id] ?? []
    }

    func updateBody(of id: UUID, to body: String) {
        guard let idx = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[idx].body = body
        notes[idx].title = Note.deriveTitle(from: body, fallback: notes[idx].title)
        notes[idx].updatedAt = .now
        markdownFlags[id] = MarkdownDetector.looksLikeMarkdown(body)
        parsedCache[id] = MarkdownParser.parse(body)
        snippetCache[id] = Self.makeSnippet(body)
        scheduleSave(notes[idx])
    }

    func isMarkdown(_ id: UUID) -> Bool {
        markdownFlags[id] ?? false
    }

    func rename(id: UUID, to newTitle: String) {
        guard let idx = notes.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = newTitle.trimmingCharacters(in: .whitespaces)
        notes[idx].title = trimmed.isEmpty ? "Untitled" : trimmed
        notes[idx].updatedAt = .now
        scheduleSave(notes[idx])
    }

    func addNote() {
        let note = Note(title: "Untitled", body: "")
        notes.insert(note, at: 0)
        markdownFlags[note.id] = false
        parsedCache[note.id] = []
        snippetCache[note.id] = ""
        selectedID = note.id
        try? store.save(note)
        scheduleOrderSave()
    }

    func closeNote(id: UUID) {
        guard let idx = notes.firstIndex(where: { $0.id == id }) else { return }
        try? store.delete(id: id)
        notes.remove(at: idx)
        modes[id] = nil
        markdownFlags[id] = nil
        parsedCache[id] = nil
        snippetCache[id] = nil
        if notes.isEmpty {
            addNote()
        } else if selectedID == id {
            selectedID = notes[min(idx, notes.count - 1)].id
        }
        scheduleOrderSave()
    }

    func select(_ id: UUID) {
        selectedID = id
    }

    func mode(of id: UUID) -> ViewMode {
        modes[id] ?? .edit
    }

    func setMode(_ mode: ViewMode, for id: UUID) {
        modes[id] = mode
    }

    struct SearchHit: Identifiable {
        let note: Note
        let matchCount: Int
        let preview: String
        var id: UUID { note.id }
    }

    func search(_ query: String) -> [SearchHit] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return notes.map { SearchHit(note: $0, matchCount: 0, preview: snippetCache[$0.id] ?? "") }
        }
        let needle = trimmed.lowercased()
        var hits: [SearchHit] = []
        for note in notes {
            let title = note.title.lowercased()
            let body = note.body.lowercased()
            let titleCount = title.components(separatedBy: needle).count - 1
            let bodyCount = body.components(separatedBy: needle).count - 1
            let total = titleCount + bodyCount
            guard total > 0 else { continue }
            hits.append(SearchHit(
                note: note,
                matchCount: total,
                preview: Self.matchPreview(body: note.body, needle: trimmed)
            ))
        }
        return hits
    }

    private static func matchPreview(body: String, needle: String) -> String {
        guard let range = body.range(of: needle, options: .caseInsensitive) else {
            return ""
        }
        let start = body.index(range.lowerBound, offsetBy: -30, limitedBy: body.startIndex) ?? body.startIndex
        let end = body.index(range.upperBound, offsetBy: 60, limitedBy: body.endIndex) ?? body.endIndex
        var snippet = String(body[start..<end])
        snippet = snippet.replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespaces)
        let prefix = start > body.startIndex ? "…" : ""
        let suffix = end < body.endIndex ? "…" : ""
        return prefix + snippet + suffix
    }

    func move(_ id: UUID, toIndex destination: Int) {
        guard let from = notes.firstIndex(where: { $0.id == id }) else { return }
        let dest = max(0, min(destination, notes.count - 1))
        if from == dest { return }
        let note = notes.remove(at: from)
        let insertAt = min(dest, notes.count)
        notes.insert(note, at: insertAt)
        scheduleOrderSave()
    }

    private func scheduleSave(_ note: Note) {
        saveTasks[note.id]?.cancel()
        saveTasks[note.id] = Task { @MainActor [store] in
            try? await Task.sleep(for: .milliseconds(300))
            if Task.isCancelled { return }
            try? store.save(note)
        }
    }

    private func scheduleOrderSave() {
        orderSaveTask?.cancel()
        let ids = notes.map(\.id)
        orderSaveTask = Task { @MainActor [store] in
            try? await Task.sleep(for: .milliseconds(150))
            if Task.isCancelled { return }
            try? store.saveOrder(ids)
        }
    }

    private static func makeSnippet(_ body: String) -> String {
        var lines = body.split(separator: "\n", omittingEmptySubsequences: false)
        if !lines.isEmpty { lines.removeFirst() }
        let cleaned = lines.joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "  ", with: " ")
        if cleaned.isEmpty { return "No additional text" }
        return cleaned.count <= 60 ? cleaned : String(cleaned.prefix(58)) + "…"
    }
}
