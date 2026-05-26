# Ghostinote — Overview

A **native macOS** note-taking overlay that stays **invisible during screen sharing**.

You can see and edit your notes on your own screen, but when you share your screen in Zoom, Google Meet, Microsoft Teams, Discord, OBS, QuickTime, etc., the overlay window is excluded from the captured frame. The rest of your desktop is shared normally.

## Use cases

- Reading speaker notes during a live presentation.
- Keeping a checklist or talking points visible during a sales/interview call.
- Personal reminders that should not leak when you share your screen for support.
- Glancing at meeting agendas without alt-tabbing.

## Non-goals

- Not a meeting recorder or transcription tool.
- Not a markdown editor with rich plugins — keep it minimal and fast.
- Not a cloud notes service. Notes live locally first.
- Not a hardware-level capture blocker. A phone camera pointed at your screen will still see the overlay.
- Not cross-platform in v1. macOS only (the user's primary machine).

## Core principle

The overlay must be **invisible in any screen capture initiated through macOS's standard capture APIs** — `CGWindowList*`, `CGDisplayStream`, and `ScreenCaptureKit`. All mainstream meeting and recording apps on macOS go through these.

The mechanism is a single AppKit property: `NSWindow.sharingType = .none`.

See `01-feasibility.md` for the API analysis.
