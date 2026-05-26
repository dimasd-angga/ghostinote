# Feasibility — Can a macOS window be invisible to screen capture?

**Short answer:** Yes. `NSWindow` ships with a first-class, documented API for exactly this.

## The API

```swift
window.sharingType = .none   // NSWindow.SharingType.none, raw value 0
```

`NSWindow.SharingType` values:

- `.readOnly` (default) — other processes can read pixels from this window.
- `.readWrite` — other processes can read and write pixels (rare; legacy).
- `.none` — **excluded from all standard capture paths**.

Stable since macOS 10.5 (2007). Still the correct API on macOS 14 Sonoma and macOS 15 Sequoia.

## What it actually excludes

Setting `.none` removes the window from the frames returned by:

- `CGWindowListCreateImage` / `CGWindowListCreateImageFromArray`
- `CGDisplayStream` (deprecated but still common)
- `ScreenCaptureKit` (`SCStream`, `SCScreenshotManager`) — macOS 12.3+
- The system screenshot/recording UI (`Cmd+Shift+3/4/5`)
- `AVCaptureScreenInput` (legacy AVFoundation screen capture)
- Browser `getDisplayMedia` for full-screen sharing in Chrome, Safari, Edge, Firefox

Apps confirmed to honor this on macOS (because they use the APIs above):

- Zoom, Microsoft Teams (native + web), Google Meet (web), Slack huddles, Discord, WebEx
- OBS Studio, ScreenFlow, CleanShot X, Loom, Riverside
- QuickTime Player screen recording
- macOS built-in screenshot tool

## Caveats (be honest about these)

1. **Physical capture is not blocked.** A phone camera, a webcam pointed at your screen, or an HDMI capture box on a mirrored display will see the overlay. This API only controls what the OS hands to software.
2. **Kernel-mode capture drivers** (rare, enterprise monitoring software like some MDM agents) may bypass it. Consumer meeting apps do not.
3. **External display mirroring** via a separate HDMI-out signal also bypasses (it's a physical signal, not an API).
4. **Apps that read framebuffers via `IOSurface` directly** are not affected by `sharingType`. None of the mainstream meeting apps do this.

All four go in the in-app trust panel (v1.0). We tell users plainly so they don't discover the gap during a high-stakes meeting.

## Why this is enough for the product promise

Every common scenario — "I'm on Zoom, I'm sharing my screen, I want to see my notes" — flows through `ScreenCaptureKit` or `CGWindowListCreateImage` under the hood. Setting `sharingType = .none` covers all of them with one line of AppKit code. No private APIs, no kernel extensions, no entitlements beyond a normal app.
