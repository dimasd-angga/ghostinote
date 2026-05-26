# Ghostinote — Docs

Planning and design documents. All AI-generated `.md` lives here, not in `app/`.

**Stack:** native macOS (Swift + AppKit + SwiftUI). macOS only in v1.

- [`00-overview.md`](00-overview.md) — what ghostinote is and isn't.
- [`01-feasibility.md`](01-feasibility.md) — can a macOS window be invisible to screen capture? (Yes — `NSWindow.sharingType = .none`.)
- [`02-architecture.md`](02-architecture.md) — Swift/AppKit + SwiftUI structure, project layout, window properties.
- [`03-platform-apis.md`](03-platform-apis.md) — the exact AppKit API + Swift snippet for capture exclusion, and a runtime self-check.
- [`04-roadmap.md`](04-roadmap.md) — v0.1 → v1.0+ feature plan.
- [`05-decisions.md`](05-decisions.md) — why we made the load-bearing calls.

Source code is in [`../app/`](../app/).
