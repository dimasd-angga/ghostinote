# Architecture

## Stack

- **Language:** Swift 5.10+ (Swift 6 ready).
- **UI:** SwiftUI for the editor surface, hosted inside an AppKit `NSWindow` (so we get full window-level control: `sharingType`, `level`, `collectionBehavior`, etc.).
- **Window shell:** AppKit — `NSWindow` subclass `OverlayWindow`, owned by an `NSWindowController`. SwiftUI alone hides too much window machinery; AppKit gives us the knobs we need.
- **Persistence:** local files in `~/Library/Application Support/Ghostinote/`, written with `FileManager` + `Data`. SQLite (via GRDB) is a v0.4 option if we add multi-note search.
- **App lifecycle:** `NSApplicationDelegate` (not the pure SwiftUI `App` lifecycle) so we can run as a menu-bar/accessory app and create custom windows imperatively.

## Why native Swift instead of Tauri / Electron

- **Direct API access.** `window.sharingType = .none` is one line. No FFI, no Rust↔Cocoa bridges.
- **Smallest possible footprint.** A SwiftUI/AppKit app idles at ~30 MB RAM and a few MB on disk. The overlay is meant to live in the menu bar across many meetings; we don't want a webview tax.
- **First-class macOS integration.** Menu bar, global hotkeys (`MASShortcut` or `Carbon RegisterEventHotKey`), Spaces behavior, focus handling, all native.
- **Single platform target.** No abstraction needed — Linux/Windows aren't in scope.

## Project layout

```
ghostinote/
├── docs/                       # all planning .md (AI-generated)
└── app/
    ├── Package.swift           # Swift Package manifest (buildable from CLI)
    ├── Ghostinote.xcodeproj/   # (added on first `xed .` or by `xcodegen` later)
    ├── Sources/
    │   └── Ghostinote/
    │       ├── App/
    │       │   ├── AppDelegate.swift
    │       │   └── main.swift
    │       ├── Window/
    │       │   ├── OverlayWindow.swift       # NSWindow subclass
    │       │   └── OverlayWindowController.swift
    │       ├── Capture/
    │       │   └── CaptureExclusion.swift    # one-liner wrapper + verification
    │       ├── Editor/
    │       │   ├── EditorView.swift          # SwiftUI
    │       │   └── NoteStore.swift
    │       ├── MenuBar/
    │       │   └── StatusItemController.swift
    │       └── Resources/
    │           └── (icons, Info.plist fragments)
    └── Tests/
        └── GhostinoteTests/
            └── CaptureExclusionTests.swift
```

`docs/` holds every planning markdown file. `app/` holds only source + Swift Package/Xcode files.

## Window properties

`OverlayWindow` is initialized with:

| Property | Value | Why |
|---|---|---|
| `styleMask` | `[.borderless, .resizable]` | Custom chrome; user-resizable. |
| `level` | `.floating` (or `.statusBar` for above-fullscreen) | Stays above presentation slides. |
| `collectionBehavior` | `[.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]` | Visible across Spaces and over fullscreen apps. |
| `isOpaque` | `false` | Allow translucency. |
| `backgroundColor` | `.clear` | Frosted/translucent look via `NSVisualEffectView`. |
| `hasShadow` | `true` | Subtle separation from desktop. |
| `isMovableByWindowBackground` | `true` | Drag from anywhere. |
| **`sharingType`** | **`.none`** | **Excludes from screen capture.** |

Set `sharingType = .none` **before** `makeKeyAndOrderFront(_:)` so the window is never captured even briefly during launch.

## App style

- `LSUIElement = true` in `Info.plist` — runs as an *accessory* app (no Dock icon, no main menu). The user controls it from a menu-bar item.
- The overlay window is opened from the menu bar; closing it does not quit the app.

## Threat model alignment

- The app makes one product promise: *"will not appear in a software-mediated screen share."* The `sharingType = .none` line is the entire enforcement mechanism. We add a **runtime self-check** (`CaptureExclusion.verify()` in v1.0) that calls `CGWindowListCreateImage` against our own window-ID and confirms the returned image excludes us. If it ever fails, we surface a red banner immediately.

## Build & run

- From CLI: `cd app && swift build && swift run Ghostinote`.
- From Xcode: `open Package.swift` (Xcode synthesizes a project from the manifest) or generate a full `.xcodeproj` later with XcodeGen if we need richer build settings (entitlements, signing, etc.).

## Error handling convention

Swift uses `throws` + typed errors. Every fallible function in `Capture/`, `Editor/NoteStore`, etc. throws a domain-specific `Error` enum. We map to user-visible messages in one place (the menu bar / banner UI) rather than swallowing errors. Equivalent in spirit to the Rust `anyhow::Result` + `.context()` convention used elsewhere in the `personal/` repo.
