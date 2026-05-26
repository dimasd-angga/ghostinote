import Foundation
import Observation

@MainActor
@Observable
final class NotesViewModel {
    private(set) var notes: [Note]
    var selectedID: UUID

    private let store: NoteStore
    private var saveTasks: [UUID: Task<Void, Never>] = [:]

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
                - Click **+** to add another tab
                - Double-click a tab to rename it
                """
            )
            self.notes = [seed]
            self.selectedID = seed.id
            try? store.save(seed)
        } else {
            self.notes = loaded
            self.selectedID = loaded.first!.id
        }
    }

    var selected: Note {
        notes.first(where: { $0.id == selectedID }) ?? notes[0]
    }

    func body(of id: UUID) -> String {
        notes.first(where: { $0.id == id })?.body ?? ""
    }

    func updateBody(of id: UUID, to body: String) {
        guard let idx = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[idx].body = body
        notes[idx].title = Note.deriveTitle(from: body, fallback: notes[idx].title)
        notes[idx].updatedAt = .now
        scheduleSave(notes[idx])
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
        selectedID = note.id
        try? store.save(note)
    }

    func closeNote(id: UUID) {
        guard let idx = notes.firstIndex(where: { $0.id == id }) else { return }
        try? store.delete(id: id)
        notes.remove(at: idx)
        if notes.isEmpty {
            addNote()
        } else if selectedID == id {
            selectedID = notes[min(idx, notes.count - 1)].id
        }
    }

    func select(_ id: UUID) {
        selectedID = id
    }

    private func scheduleSave(_ note: Note) {
        saveTasks[note.id]?.cancel()
        saveTasks[note.id] = Task { @MainActor [store] in
            try? await Task.sleep(for: .milliseconds(300))
            if Task.isCancelled { return }
            try? store.save(note)
        }
    }
}
