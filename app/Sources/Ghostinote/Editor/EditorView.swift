import SwiftUI

struct EditorView: View {
    @State private var viewModel = NotesViewModel()
    @Bindable var visibility: CaptureVisibility

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

    private var isMarkdown: Bool {
        MarkdownDetector.looksLikeMarkdown(currentText.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider().opacity(0.3)
            TabBar(viewModel: viewModel)
            Divider().opacity(0.3)

            if mode.wrappedValue == .preview && isMarkdown {
                MarkdownView(source: currentText.wrappedValue)
            } else {
                TextEditor(text: currentText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .padding(8)
            }
        }
        .onChange(of: currentText.wrappedValue) { _, newValue in
            if mode.wrappedValue == .preview, !MarkdownDetector.looksLikeMarkdown(newValue) {
                viewModel.setMode(.edit, for: viewModel.selectedID)
            }
        }
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            Button(action: { visibility.toggle() }) {
                HStack(spacing: 6) {
                    Image(systemName: visibility.isHidden ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 10))
                    Circle()
                        .fill(visibility.isHidden ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(visibility.isHidden ? "Capture-protected" : "Visible in screenshare")
                        .font(.caption)
                        .foregroundStyle(visibility.isHidden ? .secondary : Color.orange)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(visibility.isHidden
                  ? "Click to make this window visible to screen sharing"
                  : "Click to hide this window from screen sharing")

            Spacer()

            if isMarkdown {
                Picker("", selection: mode) {
                    Text("Edit").tag(ViewMode.edit)
                    Text("Preview").tag(ViewMode.preview)
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
