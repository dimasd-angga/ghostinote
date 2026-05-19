import AppKit
import SwiftUI

struct CodeEditor: NSViewRepresentable {
    @Binding var text: String
    var matchRanges: [NSRange]
    var currentMatchIndex: Int?

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSTextView.scrollableTextView()
        guard let textView = scroll.documentView as? NSTextView else { return scroll }

        textView.delegate = context.coordinator
        textView.font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.isRichText = false
        textView.allowsUndo = true
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 6, height: 8)
        textView.string = text

        scroll.drawsBackground = false
        scroll.borderType = .noBorder
        scroll.hasVerticalScroller = true
        scroll.hasHorizontalScroller = false
        scroll.autohidesScrollers = true

        applyHighlights(to: textView)
        return scroll
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }

        if textView.string != text {
            let selected = textView.selectedRange()
            textView.string = text
            // Best-effort selection restore so typing remote-edits don't jump the cursor.
            let clamped = NSRange(
                location: min(selected.location, (text as NSString).length),
                length: 0
            )
            textView.setSelectedRange(clamped)
        }
        applyHighlights(to: textView)
    }

    private func applyHighlights(to textView: NSTextView) {
        guard let storage = textView.textStorage else { return }
        let full = NSRange(location: 0, length: (textView.string as NSString).length)
        storage.removeAttribute(.backgroundColor, range: full)

        let mainHL = NSColor.systemYellow.withAlphaComponent(0.35)
        let activeHL = NSColor.systemOrange.withAlphaComponent(0.55)

        for (idx, range) in matchRanges.enumerated() where range.location + range.length <= full.length {
            let color = (idx == currentMatchIndex) ? activeHL : mainHL
            storage.addAttribute(.backgroundColor, value: color, range: range)
        }

        if let idx = currentMatchIndex, idx < matchRanges.count {
            let active = matchRanges[idx]
            textView.scrollRangeToVisible(active)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CodeEditor
        init(_ parent: CodeEditor) { self.parent = parent }

        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            parent.text = tv.string
        }
    }
}
