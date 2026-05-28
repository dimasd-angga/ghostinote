import SwiftUI

struct EditorView: View {
    @State private var viewModel = NotesViewModel()
    @AppStorage("Sidebar.visible") private var sidebarVisible: Bool = true
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

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider().opacity(0.3)
            HStack(spacing: 0) {
                if sidebarVisible {
                    Sidebar(viewModel: viewModel)
                    Divider().opacity(0.3)
                }
                editor
            }
        }
    }

    @ViewBuilder
    private var editor: some View {
        if mode.wrappedValue == .preview {
            MarkdownView(blocks: viewModel.parsedBlocks(of: viewModel.selectedID))
        } else {
            TextEditor(text: currentText)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(8)
        }
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
