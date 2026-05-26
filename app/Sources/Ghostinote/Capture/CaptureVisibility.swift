import AppKit
import Foundation
import Observation

@MainActor
@Observable
final class CaptureVisibility {
    private static let storageKey = "CaptureVisibility.hidden"

    private weak var window: NSWindow?
    private let defaults: UserDefaults

    var isHidden: Bool {
        didSet {
            guard oldValue != isHidden else { return }
            defaults.set(isHidden, forKey: Self.storageKey)
            if let window {
                CaptureExclusion.setHidden(isHidden, on: window)
            }
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: Self.storageKey) == nil {
            self.isHidden = true
        } else {
            self.isHidden = defaults.bool(forKey: Self.storageKey)
        }
    }

    func attach(to window: NSWindow) {
        self.window = window
        CaptureExclusion.setHidden(isHidden, on: window)
    }

    func toggle() {
        isHidden.toggle()
    }
}
