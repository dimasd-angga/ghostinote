import AppKit
import SwiftUI

final class OverlayWindowController: NSWindowController {
    private let visibility: CaptureVisibility

    @MainActor
    convenience init() {
        let frame = NSRect(x: 200, y: 200, width: 620, height: 380)
        let window = OverlayWindow(contentRect: frame)
        let visibility = CaptureVisibility()

        let hostingView = NSHostingView(rootView: EditorView(visibility: visibility))
        hostingView.frame = window.contentView?.bounds ?? frame
        hostingView.autoresizingMask = [.width, .height]

        let visualEffect = NSVisualEffectView(frame: hostingView.bounds)
        visualEffect.material = .hudWindow
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.autoresizingMask = [.width, .height]
        visualEffect.addSubview(hostingView)

        window.contentView = visualEffect

        self.init(window: window, visibility: visibility)
        visibility.attach(to: window)
    }

    @MainActor
    init(window: NSWindow?, visibility: CaptureVisibility) {
        self.visibility = visibility
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func showOverlay() {
        window?.makeKeyAndOrderFront(nil)
    }
}
