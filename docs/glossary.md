# Glossary

Terms used across the docs.
- **Visual effect view** — `NSVisualEffectView`, AppKit's frosted/translucent background view, used here to give the overlay its HUD look.
- **ScreenCaptureKit (SCK)** — Apple's modern screen-capture framework, introduced in macOS 12.3, replacing `CGDisplayStream`.
- **Capture exclusion** — the mechanism by which a window is omitted from the pixels returned to apps that request a screen capture.
- **`sharingType`** — `NSWindow` property that controls capture exclusion. `.none` excludes; `.readOnly` is the default.
- **Accessory app** — an app with `LSUIElement = true` (or `setActivationPolicy(.accessory)`) that has no Dock icon and no menu bar of its own.
- **`getDisplayMedia`** — the W3C Web API used by browsers (and meeting webapps) to request screen capture. Goes through the OS and honors `sharingType`.
- **Active CPU** — a macOS scheduling/billing concept; not relevant for desktop apps, only mentioned in passing for backend services.
