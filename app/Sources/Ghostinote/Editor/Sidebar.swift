import SwiftUI
import UniformTypeIdentifiers

struct Sidebar: View {
    @Bindable var viewModel: NotesViewModel
    @State private var renamingID: UUID?
    @State private var renameDraft: String = ""
    @State private var dropTargetIndex: Int?
    @State private var searchQuery: String = ""
    @FocusState private var searchFocused: Bool

    private var hits: [NotesViewModel.SearchHit] {
        viewModel.search(searchQuery)
    }

    private var isSearching: Bool {
        !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            searchField
            Divider().opacity(0.3)
            list
        }
        .frame(width: 220)
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
        .padding(.top, 6)
        .padding(.bottom, 2)
    }

    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
            TextField("Search notes", text: $searchQuery)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .focused($searchFocused)
            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .help("Clear search")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.primary.opacity(0.06))
        )
        .padding(.horizontal, 10)
        .padding(.bottom, 6)
    }

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                if hits.isEmpty && isSearching {
                    Text("No matches")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }
                ForEach(Array(hits.enumerated()), id: \.element.id) { index, hit in
                    row(for: hit, at: index)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
    }

    @ViewBuilder
    private func row(for hit: NotesViewModel.SearchHit, at index: Int) -> some View {
        let note = hit.note
        let isSelected = note.id == viewModel.selectedID
        let isRenaming = note.id == renamingID
        let isDropTarget = dropTargetIndex == index

        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                if isRenaming {
                    TextField("", text: $renameDraft, onCommit: commitRename)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, weight: .semibold))
                        .onExitCommand(perform: cancelRename)
                } else {
                    highlightedText(note.title.isEmpty ? "Untitled" : note.title)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                }
                Spacer(minLength: 4)
                if isSearching && hit.matchCount > 0 {
                    Text("\(hit.matchCount)")
                        .font(.system(size: 9, weight: .semibold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(
                            Capsule().fill(Color.accentColor.opacity(0.25))
                        )
                        .foregroundStyle(Color.accentColor)
                }
            }

            HStack(spacing: 6) {
                highlightedText(isSearching && !hit.preview.isEmpty ? hit.preview : viewModel.snippet(of: note.id))
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

    private func highlightedText(_ string: String) -> Text {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return Text(string) }

        var attributed = AttributedString(string)
        var searchStart = attributed.startIndex
        while searchStart < attributed.endIndex,
              let range = attributed[searchStart...].range(of: trimmed, options: .caseInsensitive) {
            attributed[range].backgroundColor = .yellow.opacity(0.4)
            attributed[range].foregroundColor = .primary
            searchStart = range.upperBound
        }
        return Text(attributed)
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
