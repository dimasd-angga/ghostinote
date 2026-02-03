# Research notes

Short notes captured while learning the AppKit / capture pipeline.
- Tested: launching while another full-screen Space is active - overlay appears once we add .fullScreenAuxiliary to collectionBehavior.
- Observation: hiding the overlay via orderOut() and re-showing it preserves the sharingType setting. No need to re-apply.
- Open question: does the Sidecar (iPad as second screen) capture path bypass sharingType? Untested.
- Open question: do Loom and Riverside use ScreenCaptureKit yet? Anecdotal reports say yes. Verify before claiming.
- Verified: macOS built-in screenshot (Cmd+Shift+5) excludes the overlay in both 'screenshot' and 'recording' modes.
- Tested: rapidly toggling sharingType in a debugger does not crash; the change is observed on the next frame.
- Observation: when the overlay is on a secondary display, behavior is identical - sharingType is per-window, not per-display.
