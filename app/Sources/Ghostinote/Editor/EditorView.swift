import SwiftUI

struct EditorView: View {
    @State private var viewModel = NotesViewModel()
    @State private var mode: Mode = .edit

    private enum Mode { case edit, preview }

    private var currentText: Binding<String> {
        Binding(
            get: { viewModel.body(of: viewModel.selectedID) },
            set: { viewModel.updateBody(of: viewModel.selectedID, to: $0) }
        )
    }

    private var isMarkdown: Bool {
        MarkdownDetector.looksLikeMarkdown(currentText.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider().opacity(0.3)
            TabBar(viewModel: viewModel)
            Divider().opacity(0.3)

            Group {
                switch mode {
                case .edit:
                    TextEditor(text: currentText)
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .id(viewModel.selectedID)
                case .preview:
                    MarkdownView(source: currentText.wrappedValue)
                }
            }
        }
        .onChange(of: viewModel.selectedID) { _, _ in
            if mode == .preview, !isMarkdown { mode = .edit }
        }
        .onChange(of: currentText.wrappedValue) { _, newValue in
            if mode == .preview, !MarkdownDetector.looksLikeMarkdown(newValue) {
                mode = .edit
            }
        }
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            Text("Capture-protected")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            if isMarkdown {
                Picker("", selection: $mode) {
                    Text("Edit").tag(Mode.edit)
                    Text("Preview").tag(Mode.preview)
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
                .labelsHidden()
            } else {
                Text("Plain text")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .padding(.leading, 70)
    }
}
