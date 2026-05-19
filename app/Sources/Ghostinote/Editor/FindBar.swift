import SwiftUI

struct FindBar: View {
    @Binding var query: String
    let matchCount: Int
    let currentIndex: Int?
    let onPrev: () -> Void
    let onNext: () -> Void
    let onClose: () -> Void
    @FocusState var fieldFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)

            TextField("Find in note", text: $query)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .focused($fieldFocused)
                .onSubmit(onNext)

            Text(counterText)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(minWidth: 50, alignment: .trailing)

            Button(action: onPrev) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 22, height: 20)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(matchCount == 0)
            .help("Previous match (Shift+Return)")

            Button(action: onNext) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 22, height: 20)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(matchCount == 0)
            .help("Next match (Return)")

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 22, height: 20)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Close (Esc)")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Rectangle()
                .fill(Color(nsColor: .textBackgroundColor).opacity(0.6))
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(.separator),
            alignment: .bottom
        )
    }

    private var counterText: String {
        if matchCount == 0 {
            return query.isEmpty ? "" : "No results"
        }
        let current = (currentIndex ?? 0) + 1
        return "\(current) of \(matchCount)"
    }
}
