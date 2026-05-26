import AppKit
import SwiftUI

final class OverlayWindowController: NSWindowController {
    convenience init() {
        let frame = NSRect(x: 200, y: 200, width: 420, height: 320)
        let window = OverlayWindow(contentRect: frame)

        let hostingView = NSHostingView(rootView: EditorView())
        hostingView.frame = window.contentView?.bounds ?? frame
        hostingView.autoresizingMask = [.width, .height]

        let visualEffect = NSVisualEffectView(frame: hostingView.bounds)
        visualEffect.material = .hudWindow
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.autoresizingMask = [.width, .height]
        visualEffect.addSubview(hostingView)

        window.contentView = visualEffect

        self.init(window: window)
    }

    func showOverlay() {
        window?.makeKeyAndOrderFront(nil)
    }
}
