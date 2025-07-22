# Research notes

Short notes captured while learning the AppKit / capture pipeline.
- Tested: launching while another full-screen Space is active - overlay appears once we add .fullScreenAuxiliary to collectionBehavior.
- Observation: hiding the overlay via orderOut() and re-showing it preserves the sharingType setting. No need to re-apply.
- Open question: does the Sidecar (iPad as second screen) capture path bypass sharingType? Untested.
- Open question: do Loom and Riverside use ScreenCaptureKit yet? Anecdotal reports say yes. Verify before claiming.
- Verified: macOS built-in screenshot (Cmd+Shift+5) excludes the overlay in both 'screenshot' and 'recording' modes.
- Tested: rapidly toggling sharingType in a debugger does not crash; the change is observed on the next frame.
- Observation: when the overlay is on a secondary display, behavior is identical - sharingType is per-window, not per-display.
- Found: if the user disables 'Displays have separate Spaces' in System Settings, the overlay still works on all monitors.
- Verified: Google Meet via Chrome 126 getDisplayMedia correctly skips our window.
- Verified: QuickTime Player's screen recording cleanly excludes the overlay.
- Confirmed: NSVisualEffectView does not affect capture exclusion - the exclusion is per-window, not per-view.
- Initial test: minimal NSWindow with sharingType=.none works in isolation. Need to confirm with NSVisualEffectView background.
