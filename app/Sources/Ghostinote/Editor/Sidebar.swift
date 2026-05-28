import SwiftUI

struct Sidebar: View {
    @Bindable var viewModel: NotesViewModel
    @State private var renamingID: UUID?
    @State private var renameDraft: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider().opacity(0.3)
            list
        }
        .frame(width: 200)
        .background(Color(nsColor: .textBackgroundColor).opacity(0.25))
    }

    private var header: some View {
        HStack {
            Text("Notes")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: { viewModel.addNote() }) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("New note")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
    }

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(viewModel.notes) { note in
                    row(for: note)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
    }

    @ViewBuilder
    private func row(for note: Note) -> some View {
        let isSelected = note.id == viewModel.selectedID
        let isRenaming = note.id == renamingID

        VStack(alignment: .leading, spacing: 2) {
            if isRenaming {
                TextField("", text: $renameDraft, onCommit: commitRename)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, weight: .semibold))
                    .onExitCommand(perform: cancelRename)
            } else {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)
            }

            HStack(spacing: 6) {
                Text(snippet(of: note))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text(relativeTimestamp(note.updatedAt))
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isSelected ? Color.primary.opacity(0.12) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { beginRename(note) }
        .onTapGesture { viewModel.select(note.id) }
        .contextMenu {
            Button("Rename") { beginRename(note) }
            Button("Duplicate") { duplicate(note) }
            if viewModel.notes.count > 1 {
                Divider()
                Button("Delete", role: .destructive) { viewModel.closeNote(id: note.id) }
            }
        }
    }

    private func snippet(of note: Note) -> String {
        let bodyMinusFirstLine: String = {
            var lines = note.body.split(separator: "\n", omittingEmptySubsequences: false)
            if !lines.isEmpty { lines.removeFirst() }
            return lines.joined(separator: " ")
        }()
        let cleaned = bodyMinusFirstLine
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "  ", with: " ")
        if cleaned.isEmpty { return "No additional text" }
        return cleaned.count <= 60 ? cleaned : String(cleaned.prefix(58)) + "…"
    }

    private func relativeTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: .now)
    }

    private func beginRename(_ note: Note) {
        renameDraft = note.title
        renamingID = note.id
    }

    private func commitRename() {
        if let id = renamingID {
            viewModel.rename(id: id, to: renameDraft)
        }
        renamingID = nil
    }

    private func cancelRename() {
        renamingID = nil
    }

    private func duplicate(_ note: Note) {
        viewModel.addNote()
        let newID = viewModel.selectedID
        viewModel.updateBody(of: newID, to: note.body)
        viewModel.rename(id: newID, to: note.title + " (copy)")
    }
}
