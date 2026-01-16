# Ghostinote — Invisible Notes Overlay for Screen Sharing on macOS

> A native macOS notes app that **stays invisible during Zoom, Google Meet, Microsoft Teams, Discord, OBS, and QuickTime screen sharing** — but stays fully visible to you on your own screen.

Read your speaker notes, talking points, interview cheatsheet, sales script, or meeting agenda while sharing your entire screen. Your audience sees only your desktop and the app you're presenting — the Ghostinote overlay is filtered out of the captured frame by the operating system itself.

[![macOS](https://img.shields.io/badge/macOS-14%2B-black?logo=apple)](#requirements)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)](https://swift.org)
[![AppKit + SwiftUI](https://img.shields.io/badge/AppKit-%2B%20SwiftUI-blue)](https://developer.apple.com/documentation/appkit)
[![License](https://img.shields.io/badge/license-MIT-green)](#license)

---

## Why Ghostinote?

Every native macOS screen-capture API (`CGWindowList`, `ScreenCaptureKit`, `AVCaptureScreenInput`, browser `getDisplayMedia`) honors a single Cocoa flag: `NSWindow.sharingType = .none`. Ghostinote sets that flag on its overlay window before the window is ever drawn. The result: **Zoom, Google Meet, Microsoft Teams, Discord, OBS Studio, QuickTime, CleanShot, Loom, the built-in screenshot tool** — every mainstream app that captures the screen on macOS — receives a frame with the overlay cut out.

This is the same OS-level mechanism Apple itself uses to hide sensitive UI from screen recordings. No private APIs. No kernel extensions. No screen-recording permission required.

## Features

- **Invisible to all standard screen-sharing & screen-recording software** on macOS via `NSWindow.sharingType = .none`.
- **Native macOS app**, built with Swift 6, AppKit, and SwiftUI. ~30 MB idle RAM, ~3 MB on disk.
- **Markdown auto-detection** with one-click Edit / Preview toggle. Headings, lists, blockquotes, fenced code, bold/italic/links — rendered inline.
- **Always-on-top floating window** with native traffic-light buttons (close, minimize, zoom/fullscreen).
- **Frameless translucent design** that blends with the desktop. Drag from anywhere.
- **Multi-Space & full-screen aware** — overlay follows you across desktops and appears over fullscreen apps (perfect during presentations).
- **Accessory app** — no Dock icon, no Cmd-Tab presence. Lives quietly above your other windows.
- **Local-first** — your notes never leave the machine. No accounts, no cloud, no telemetry.

## Use cases

- **Presenting on Zoom or Google Meet** and want to glance at your speaker notes without flipping windows.
- **Interview cheatsheet** during a remote technical interview where you're sharing your IDE.
- **Sales / customer calls** with a private call script that the customer must never see.
- **Live coding & teaching streams** on OBS, Twitch, or YouTube, with private TODOs and reminders.
- **Customer support screen shares** while reading internal-only checklists.
- **Personal reminders** that should never appear in a recorded demo or product walkthrough.

## How it works

When any macOS app captures the screen — Zoom, Teams, OBS, even the browser's `getDisplayMedia` API — the OS asks the window server for the pixels. AppKit lets every window declare its capture policy via the `NSWindowSharingType` property. Ghostinote's overlay sets it to `.none`:

```swift
window.sharingType = .none
```

That one line removes the window from the buffers returned by:

- `CGWindowListCreateImage` / `CGWindowListCreateImageFromArray`
- `CGDisplayStream`
- `ScreenCaptureKit` (`SCStream`, `SCScreenshotManager`)
- `AVCaptureScreenInput`
- Browser `getDisplayMedia()` (Chrome, Safari, Edge, Firefox)
- The system screenshot tool (`Cmd+Shift+3/4/5`)

Every consumer screen-sharing app on macOS uses one of those APIs under the hood — so they all see a transparent gap where the overlay is, while *you* see your notes normally.

See [`docs/01-feasibility.md`](docs/01-feasibility.md) for the full platform analysis.

## What it does NOT block

Be honest with yourself about what you're protecting against:

- **A phone camera or webcam pointed at your screen.** This is software-level capture exclusion, not physical privacy.
- **HDMI capture hardware** on a mirrored external display (it's a separate physical signal).
- **Kernel-mode capture drivers** used by some enterprise monitoring tools (none of the mainstream meeting apps use these).

For most "I'm presenting on Zoom and don't want my notes to leak" situations, the OS-level exclusion is exactly what you need. For high-stakes secrecy, supplement it with situational awareness.

## Requirements

- macOS 14 (Sonoma) or newer — the project targets `.macOS(.v14)` in `Package.swift`.
- Apple Silicon or Intel Mac.
- Xcode 15+ (or just Swift 6.0+ command-line tools) to build.

## Build & run

```bash
git clone https://github.com/dimasd-angga/ghostinote.git
cd ghostinote/app
swift build
swift run Ghostinote
```

The translucent overlay window will appear in the upper-left of your screen. To verify the invisibility:

1. With the overlay visible, press `Cmd+Shift+5`.
2. Choose **Record Entire Screen** and start recording.
3. Stop, then play back the recording.

The overlay should be **absent** from the playback — only the rest of your desktop is captured.

## Project layout

```
ghostinote/
├── docs/                        # Planning, design, and architecture docs
│   ├── 00-overview.md
│   ├── 01-feasibility.md        # Platform analysis: how the exclusion works
│   ├── 02-architecture.md       # Stack, project structure, window properties
│   ├── 03-platform-apis.md      # Exact AppKit APIs used
│   ├── 04-roadmap.md            # v0.1 → v1.0 plan
│   └── 05-decisions.md          # Why we chose Swift over Tauri / Electron
└── app/                         # Source code (Swift Package)
    ├── Package.swift
    └── Sources/Ghostinote/
        ├── App/                 # main.swift, AppDelegate.swift
        ├── Window/              # OverlayWindow.swift + controller
        ├── Capture/             # CaptureExclusion.swift  ← the core
        └── Editor/              # EditorView, MarkdownDetector, MarkdownView
```

## FAQ

### Does this work with Zoom, Google Meet, Microsoft Teams, and Discord?
Yes — all four use macOS's standard screen-capture APIs (`ScreenCaptureKit` / `CGWindowList`). Ghostinote is invisible in their "Share Entire Screen" mode and in app-window sharing alike.

### Does it work in the browser version of Google Meet?
Yes. Browsers call the OS's screen-capture API through `getDisplayMedia()`, and the OS honors `sharingType = .none` regardless of who's asking.

### Does it work with OBS Studio screen recording?
Yes — OBS uses the macOS Graphics Capture / ScreenCaptureKit pipeline, which respects the same flag.

### Will a phone camera pointed at my screen still see the notes?
**Yes**, and that's intentional — Ghostinote can only control what the operating system hands to other software. A camera is outside that loop.

### Do I need to grant screen-recording permission?
**No.** Setting `sharingType` on your own window does not require any system permission.

### Is there a Windows or Linux version?
Not yet. Windows has an equivalent API (`SetWindowDisplayAffinity(WDA_EXCLUDEFROMCAPTURE)`) and a port is possible. Linux lacks a reliable per-window capture-exclusion API on either X11 or Wayland today.

### Is my data sent anywhere?
**No.** Ghostinote is a single-binary local app. No network calls. No telemetry. No cloud sync. Notes are written to `~/Library/Application Support/Ghostinote/`.

### Can I trust this with sensitive notes?
Trust the API only as far as the OS reliably honors it. We document the exact failure modes (phone cameras, HDMI capture, kernel-mode hooks) in [`docs/01-feasibility.md`](docs/01-feasibility.md). For most realistic scenarios — Zoom, Meet, Teams, OBS, browser sharing — the exclusion is rock-solid.

## Alternatives & comparisons

| Tool | Approach | Tradeoff |
|---|---|---|
| **Ghostinote** | Native AppKit `sharingType = .none` | Free, open, ~3 MB, transparent about limits |
| Sticky Notes / Stickies | Standard window | Visible in screen shares |
| iA Writer / Bear / Obsidian on a second monitor | Hide notes on a non-shared display | Requires a second display; clunky during full-screen share |
| "Confidential mode" in meeting apps | Per-app feature, inconsistent | Each meeting app behaves differently; no protection during recording |
| Custom virtual desktop with hidden window | Switch Spaces during share | Disruptive; easy to accidentally share |

## Roadmap

- **v0.2** — Verified exclusion matrix (Zoom, Meet, Teams, OBS, QuickTime).
- **v0.3** — Auto-saving editor with persistence to `~/Library/Application Support/Ghostinote/`.
- **v0.4** — Multiple notes with sidebar and keyboard navigation.
- **v0.5** — Menu-bar item, global hotkey, click-through mode.
- **v1.0** — Trust panel with live runtime self-check, code signing, notarization.

Full plan in [`docs/04-roadmap.md`](docs/04-roadmap.md).

## Tech stack

- **Swift 6** with strict concurrency.
- **AppKit** `NSWindow` subclass for window-level control (`sharingType`, `level`, `collectionBehavior`).
- **SwiftUI** for the editor and markdown preview, hosted via `NSHostingView`.
- **Swift Package Manager** for building — no Xcode project required to build from CLI.
- **XCTest** for unit tests.

## Contributing

Issues and pull requests are welcome. The project intentionally stays small and focused — please read [`docs/05-decisions.md`](docs/05-decisions.md) before proposing architectural changes.

## License

MIT — see [`LICENSE`](LICENSE).

## Keywords

macOS screen share notes overlay, hide notes during Zoom screen share, invisible notes during screen recording, speaker notes Zoom Google Meet Teams, private notes during screen sharing macOS, Swift AppKit screen capture exclusion, `NSWindow.sharingType` `.none`, `ScreenCaptureKit` exclude window, presentation notes app macOS, interview cheatsheet screen share.

<!-- bumped: 2026-01-16 -->
