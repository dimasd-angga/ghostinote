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
        viewModel.isMarkdown(viewModel.selectedID)
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
    }

    private var visibilityBinding: Binding<Bool> {
        Binding(
            get: { !visibility.isHidden },
            set: { visibility.isHidden = !$0 }
        )
    }

    private var toolbar: some View {
        HStack(spacing: 10) {
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

            Picker("", selection: mode) {
                Text("Edit").tag(ViewMode.edit)
                Text("Preview").tag(ViewMode.preview)
            }
            .pickerStyle(.segmented)
            .frame(width: 140)
            .labelsHidden()
            .disabled(!isMarkdown)
            .opacity(isMarkdown ? 1.0 : 0.5)
            .help(isMarkdown
                  ? "Switch between editing and rendered preview"
                  : "Preview is only available for markdown content")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .padding(.leading, 70)
    }
}
