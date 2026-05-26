import SwiftUI

struct EditorView: View {
    @State private var text: String = """
    # Ghostinote

    This window is **invisible** during screen share.

    - Type your notes here
    - Switch to *Preview* if it's markdown
    - `Cmd+W` closes the window (app keeps running)
    """
    @State private var mode: Mode = .edit

    private enum Mode { case edit, preview }

    private var isMarkdown: Bool {
        MarkdownDetector.looksLikeMarkdown(text)
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider().opacity(0.3)

            Group {
                switch mode {
                case .edit:
                    TextEditor(text: $text)
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .padding(8)
                case .preview:
                    MarkdownView(source: text)
                }
            }
        }
        .onChange(of: text) { _, newValue in
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
