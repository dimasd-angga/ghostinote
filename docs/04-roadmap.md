# Roadmap

macOS only. Native Swift / AppKit / SwiftUI.

## v0.1 — Skeleton (this commit)

- `docs/` and `app/` folders.
- Swift Package manifest in `app/Package.swift`.
- `main.swift` + `AppDelegate.swift` + `OverlayWindow.swift` + `CaptureExclusion.swift`.
- App launches, shows an empty translucent overlay window with `sharingType = .none`.
- No editor, no persistence yet.

## v0.2 — Capture exclusion verified

- Manual verification matrix:
  - macOS built-in screenshot (`Cmd+Shift+5` → record).
  - QuickTime Player screen recording.
  - Zoom share entire screen.
  - Google Meet (Chrome `getDisplayMedia`) share entire screen.
  - Microsoft Teams share entire screen.
  - OBS Studio display capture.
- Add `CaptureExclusion.verify(window:)` unit/integration check.
- Document expected behavior in `docs/06-verification.md` (added then).

## v0.3 — Editor

- SwiftUI `EditorView` hosted in the overlay.
- Monospace `TextEditor` with subtle background.
- Auto-save every 300 ms of idle to `~/Library/Application Support/Ghostinote/note.md`.
- Frameless, draggable from anywhere, resizable.
- Opacity slider in a small inline toolbar.

## v0.4 — Multiple notes

- Sidebar of notes (toggleable).
- Create / rename / delete.
- Hotkeys `Cmd+[` / `Cmd+]` to cycle.
- Storage moves from single file → directory of `.md` files (or SQLite if search becomes a need).

## v0.5 — Menu bar + global hotkey + click-through

- `NSStatusItem` in the menu bar.
- Global hotkey to toggle visibility (`Cmd+Shift+G`, configurable).
- "Click-through" toggle (`window.ignoresMouseEvents = true`) — overlay visible but mouse passes through to the app behind it.
- Remember window position per display.
- Light / dark adaptive.

## v1.0 — Trust panel + polish

- Trust panel showing live status of `CaptureExclusion.verify()`.
- One-click "test now": opens `Cmd+Shift+5` and prompts the user to record their screen and confirm the overlay is absent.
- Honest disclosure copy (phone camera, HDMI capture, kernel drivers).
- Universal binary (Apple Silicon + Intel).
- Code signing + notarization for distribution outside personal use.
- Sparkle auto-update (optional).

## v1.1+ — Maybe

- Markdown rendering toggle.
- Encrypted notes (passphrase at app launch, FileVault-backed).
- iCloud Drive folder sync (zero-config, no custom backend).
- Touch Bar shortcuts.

## Explicitly out of scope

- Windows / Linux ports.
- Cloud notes backend.
- AI features (would require network calls).
- Mobile clients.
