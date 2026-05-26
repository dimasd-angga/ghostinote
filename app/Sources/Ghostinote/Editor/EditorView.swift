import SwiftUI

struct EditorView: View {
    @State private var text: String = "Ghostinote\n\nThis window is invisible during screen share.\nType your notes here."

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("Capture-protected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider().opacity(0.3)

            TextEditor(text: $text)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(8)
        }
    }
}
