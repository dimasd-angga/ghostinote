import SwiftUI

struct TabBar: View {
    @Bindable var viewModel: NotesViewModel
    @State private var renamingID: UUID?
    @State private var renameDraft: String = ""

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(viewModel.notes) { note in
                    tabPill(for: note)
                }
                Button(action: { viewModel.addNote() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .semibold))
                        .frame(width: 22, height: 22)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("New note")
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 30)
    }

    @ViewBuilder
    private func tabPill(for note: Note) -> some View {
        let isSelected = note.id == viewModel.selectedID
        let isRenaming = note.id == renamingID

        HStack(spacing: 6) {
            if isRenaming {
                TextField("", text: $renameDraft, onCommit: commitRename)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11, weight: .medium))
                    .frame(minWidth: 60, maxWidth: 140)
                    .onExitCommand(perform: cancelRename)
            } else {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .frame(maxWidth: 140)
            }

            if viewModel.notes.count > 1 {
                Button(action: { viewModel.closeNote(id: note.id) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 12, height: 12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Close tab")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.primary.opacity(0.15) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? Color.primary.opacity(0.25) : Color.primary.opacity(0.08), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { beginRename(note) }
        .onTapGesture { viewModel.select(note.id) }
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
}
