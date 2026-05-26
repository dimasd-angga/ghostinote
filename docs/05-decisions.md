# Decisions log

Short record of the load-bearing choices so future-me (or future-AI) doesn't relitigate them.

## D1 — Native macOS, not web

A browser `getDisplayMedia` consumer cannot exclude its own page from capture. The OS-level exclusion APIs are only callable from a native window owner. Therefore ghostinote must be a native app.

## D2 — Swift + AppKit, not Tauri / Electron / Rust-with-FFI

The user's first machine is a Mac, and macOS exposes the exact API we need (`NSWindow.sharingType = .none`) as a one-liner in AppKit. Going through Tauri or Electron would add a Rust↔Cocoa or Node↔Cocoa bridge to call the same one line, plus a webview tax (~100–200 MB RAM for Electron, ~60 MB for Tauri's WKWebView). Native Swift gives us:

- Direct access with no FFI.
- ~30 MB idle RAM.
- First-class menu bar, Spaces, fullscreen, global-hotkey APIs.
- The smallest possible attack surface for what is meant to be a trustworthy "this won't leak" tool.

## D3 — macOS only in v1

Linux has no reliable per-window capture-exclusion API. Windows has one (`SetWindowDisplayAffinity` with `WDA_EXCLUDEFROMCAPTURE`) but the user is on a Mac, so the cross-platform abstraction would be pure speculative work. Build the Mac version well first; consider a Windows port later only if needed.

## D4 — Local-first, no network in v1

Reduces threat surface (no creds to leak), keeps install path simple (no signup), and matches the "Local-only for now" deploy choice. File sync via iCloud Drive folder is a v1.1 option, not a custom backend.

## D5 — Honest UI about limits

`sharingType = .none` does not defeat a phone camera, hardware HDMI capture, or kernel-mode capture drivers. The trust panel (v1.0) will say so plainly. Better to under-promise than have a user discover the gap mid-meeting.

## D6 — AppKit window shell, SwiftUI editor inside

Pure SwiftUI hides the `NSWindow` we need to mutate. AppKit gives us the property knobs (`sharingType`, `level`, `collectionBehavior`, `styleMask`). SwiftUI is great for the editor content — composed inside an `NSHostingView`. Best of both.

## D7 — Run as accessory app (`LSUIElement = true`)

The overlay isn't a primary app — it's a tool that lives in the menu bar and floats above other windows. No Dock icon, no main menu, no Cmd-Tab presence. Less visual clutter, less surface to leak the app's existence in shared screens.

## D8 — Self-verify capture exclusion at runtime

Don't trust the API silently. After window creation, call `CGWindowListCreateImage` on our own window ID and assert the returned image is nil/empty. If exclusion ever breaks (OS update, deprecation), we want to detect it before the user does, in a meeting.

## D9 — Docs in `docs/`, source in `app/`

Per the user's instruction: AI-generated planning docs live exclusively in `docs/`. The `app/` directory contains only source code + Swift Package / Xcode files. No `.md` inside `app/`.

## D10 — Git: no Co-Authored-By trailer, repo stays local

Per the user's instruction: commits do not include the `Co-Authored-By: Claude` trailer, and we do not initialize a GitHub remote or set visibility. The repo stays a local `git init` until the user decides otherwise.
