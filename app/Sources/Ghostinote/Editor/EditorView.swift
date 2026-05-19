import SwiftUI

struct EditorView: View {
    @State private var viewModel = NotesViewModel()
    @AppStorage("Sidebar.visible") private var sidebarVisible: Bool = true
    @Bindable var visibility: CaptureVisibility

    @State private var findVisible: Bool = false
    @State private var findQuery: String = ""
    @State private var currentMatchIndex: Int = 0
    @FocusState private var findFieldFocused: Bool

    private var currentText: Binding<String> {
        Binding(
            get: { viewModel.body(of: viewModel.selectedID) },
            set: { viewModel.updateBody(of: viewModel.selectedID, to: $0) }
        )
    }

    private var mode: Binding<ViewMode> {
        Binding(
            get: { viewModel.mode(of: viewModel.selectedID) },
            set: { viewModel.setMode($0, for: viewModel.selectedID) }
        )
    }

    private var matches: [NSRange] {
        TextMatcher.ranges(of: findQuery, in: currentText.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider().opacity(0.3)
            HStack(spacing: 0) {
                if sidebarVisible {
                    Sidebar(viewModel: viewModel)
                    Divider().opacity(0.3)
                }
                editorPane
            }
        }
        .onChange(of: viewModel.selectedID) { _, _ in
            findVisible = false
            findQuery = ""
        }
    }

    @ViewBuilder
    private var editorPane: some View {
        VStack(spacing: 0) {
            if findVisible && mode.wrappedValue == .edit {
                FindBar(
                    query: $findQuery,
                    matchCount: matches.count,
                    currentIndex: matches.isEmpty ? nil : currentMatchIndex,
                    onPrev: gotoPrev,
                    onNext: gotoNext,
                    onClose: closeFind
                )
                .onAppear { findFieldFocused = true }
                .onChange(of: findQuery) { _, _ in currentMatchIndex = 0 }
            }
            editor
        }
        .onKeyPress(.escape) {
            if findVisible {
                closeFind()
                return .handled
            }
            return .ignored
        }
        .background(findShortcut)
    }

    // A hidden zero-size button that owns the Cmd+F keyboard shortcut.
    private var findShortcut: some View {
        Button("", action: openFind)
            .keyboardShortcut("f", modifiers: .command)
            .frame(width: 0, height: 0)
            .opacity(0)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var editor: some View {
        if mode.wrappedValue == .preview {
            MarkdownView(blocks: viewModel.parsedBlocks(of: viewModel.selectedID))
        } else {
            CodeEditor(
                text: currentText,
                matchRanges: matches,
                currentMatchIndex: matches.isEmpty ? nil : currentMatchIndex
            )
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
        }
    }

    private func openFind() {
        if mode.wrappedValue == .preview { mode.wrappedValue = .edit }
        findVisible = true
        findFieldFocused = true
        if matches.isEmpty { currentMatchIndex = 0 }
    }

    private func closeFind() {
        findVisible = false
        findQuery = ""
        currentMatchIndex = 0
    }

    private func gotoNext() {
        guard !matches.isEmpty else { return }
        currentMatchIndex = (currentMatchIndex + 1) % matches.count
    }

    private func gotoPrev() {
        guard !matches.isEmpty else { return }
        currentMatchIndex = (currentMatchIndex - 1 + matches.count) % matches.count
    }

    private var visibilityBinding: Binding<Bool> {
        Binding(
            get: { !visibility.isHidden },
            set: { visibility.isHidden = !$0 }
        )
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            Button(action: { sidebarVisible.toggle() }) {
                Image(systemName: sidebarVisible ? "sidebar.left" : "sidebar.leading")
                    .font(.system(size: 13, weight: .medium))
                    .frame(width: 24, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(sidebarVisible ? "Hide notes sidebar" : "Show notes sidebar")

            Toggle(isOn: visibilityBinding) {
                EmptyView()
            }
            .toggleStyle(.switch)
            .controlSize(.mini)
            .labelsHidden()
            .help(visibility.isHidden
                  ? "Off: window is hidden from screen sharing"
                  : "On: window is visible to screen sharing")

            Image(systemName: visibility.isHidden ? "eye.slash.fill" : "eye.fill")
                .font(.system(size: 11))
                .foregroundStyle(visibility.isHidden ? .secondary : Color.orange)

            Text(visibility.isHidden ? "Capture-protected" : "Visible in screenshare")
                .font(.caption)
                .foregroundStyle(visibility.isHidden ? .secondary : Color.orange)
                .lineLimit(1)

            Spacer(minLength: 8)

            Button(action: openFind) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: 24, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Find in note (Cmd+F)")

            Picker("", selection: mode) {
                Text("Edit").tag(ViewMode.edit)
                Text("Preview").tag(ViewMode.preview)
            }
            .pickerStyle(.segmented)
            .frame(width: 140)
            .labelsHidden()
            .help("Switch between editing and rendered preview")
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .padding(.vertical, 6)
    }
}
