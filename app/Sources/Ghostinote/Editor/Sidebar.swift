import SwiftUI
import UniformTypeIdentifiers

struct Sidebar: View {
    @Bindable var viewModel: NotesViewModel
    @State private var renamingID: UUID?
    @State private var renameDraft: String = ""
    @State private var dropTargetIndex: Int?

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
                ForEach(Array(viewModel.notes.enumerated()), id: \.element.id) { index, note in
                    row(for: note, at: index)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
    }

    @ViewBuilder
    private func row(for note: Note, at index: Int) -> some View {
        let isSelected = note.id == viewModel.selectedID
        let isRenaming = note.id == renamingID
        let isDropTarget = dropTargetIndex == index

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
                Text(viewModel.snippet(of: note.id))
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
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(isSelected ? Color.primary.opacity(0.12) : Color.clear)
                if isDropTarget {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.accentColor, lineWidth: 2)
                }
            }
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
        .draggable(note.id.uuidString) {
            Text(note.title.isEmpty ? "Untitled" : note.title)
                .font(.system(size: 12, weight: .semibold))
                .padding(6)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(4)
        }
        .dropDestination(for: String.self) { items, _ in
            dropTargetIndex = nil
            guard let raw = items.first, let droppedID = UUID(uuidString: raw) else {
                return false
            }
            viewModel.move(droppedID, toIndex: index)
            return true
        } isTargeted: { targeted in
            dropTargetIndex = targeted ? index : (dropTargetIndex == index ? nil : dropTargetIndex)
        }
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
