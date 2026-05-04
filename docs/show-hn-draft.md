# Show HN launch draft

When you're ready to post, copy from here.

## Title (HN limit: 80 chars)

**Recommended:**
> Show HN: Ghostinote – Mac notes that stay invisible during Zoom screen shares

Alternates if you want to A/B mentally:
- `Show HN: A Mac notes overlay that doesn't appear in Zoom or screen recordings`
- `Show HN: Read speaker notes during screen share – they're invisible to the share`

**Avoid:**
- "AI-powered" or "revolutionary" — kills credibility instantly.
- Bracketed years like `[2026]`.
- Emoji in the title.

## URL field

`https://github.com/dimasd-angga/ghostinote`

(NOT the release page — HN ranks repos slightly better than release pages, and the README's download badge is right there.)

## First comment (post this yourself within 60 seconds of the submission landing)

> Author here. Quick context on why this exists:
>
> macOS exposes a single AppKit flag — `NSWindow.sharingType = .none` — that excludes a window from every standard screen-capture path on the system: `CGWindowList`, `ScreenCaptureKit`, `AVCaptureScreenInput`, and the `getDisplayMedia` pipeline every browser uses. Apple uses it internally to hide sensitive UI from screenshots. Setting it on your own window does not require any system permission.
>
> Ghostinote is basically a notes app wrapped around that one line, plus the small amount of plumbing it takes to make it useful (multi-note sidebar, markdown preview, draggable always-on-top window, capture-protected indicator, manual toggle for the few times you actually do want to share the notes).
>
> Honest limits, called out in the README too:
> – Does not block a phone camera pointed at your screen, HDMI capture hardware, or kernel-mode capture drivers. This is software-level OS exclusion, not anti-forensics.
> – macOS only. Windows has a similar API (`SetWindowDisplayAffinity` with `WDA_EXCLUDEFROMCAPTURE`) but isn't ported yet. Linux has no reliable per-window equivalent on either X11 or Wayland.
>
> Free, MIT-licensed, single-binary, ~700 KB, no network. Local notes only.
>
> Happy to answer questions. If anyone tests it in a meeting app I haven't already verified, please report back — the README's compat list is just what I've personally tried.

## Timing

- **Day of week:** Tuesday, Wednesday, or Thursday. Avoid Friday (dead zone) and Sunday (already crowded).
- **Time:** 8–10 AM US Eastern. That's the front-page reset window. For you in Jakarta (UTC+7), that's 8–10 PM same day.
- **Do not post on holidays / major news days** — your submission gets buried.

## What to expect

A Show HN gets one of three outcomes:
1. **Front page (top 30)** — drives 2,000–10,000 visits over 24h. Possible but not the median.
2. **"New" page only** — 50–200 visits. The median. Still useful: a couple of Hacker News users tend to file thoughtful issues.
3. **Buried in 30 min** — under 5 points, drops off "new" before anyone sees it. Don't take it personally; HN's ranking has a strong randomness component for the first hour.

To improve odds:
- Make sure the README looks correct in mobile view before posting (HN traffic is ~30% mobile).
- The download link must work. Test the DMG download path from a private window before posting.
- Be online and responsive for the first 2 hours. Reply to every comment, even one-liners. HN's algorithm boosts threads with active author engagement.

## After Show HN

Crosspost the same submission, with different titles, to:

- **r/MacApps** — title: *"I made a notes app that stays invisible during screen sharing on macOS"*
- **r/macOSBeta** or **r/macosprogramming** — title: *"Used `NSWindow.sharingType = .none` to hide a notes overlay from screen-share apps"* (more technical framing, that sub appreciates it)
- **r/swift** — title: *"Built a Mac notes overlay invisible to screen sharing — small open-source SwiftUI + AppKit project"*

Stagger by a day or two so it doesn't look like a campaign. Each sub has different mods; check the rules before posting (most require a self-post or non-promotional flair).

## Lower-effort spots (do these in parallel)

- **Twitter / X:** one post with the GitHub URL and a 5-second screen recording showing the overlay disappearing from a Zoom share preview. Tag `#macOS #SwiftUI #indiedev`. Optionally `@_inside` (Steve Troughton-Smith — he sometimes RTs niche Mac tooling) and `@daringfireball` (long shot).
- **Mastodon:** `#MacDev` and `#Swift` tags. Smaller audience but they actually engage and click.
- **Indie Hackers** — "What I built this week" thread.
- **Hacker News monthly "Ask HN: What are you working on?"** — usually posted on the 1st of the month, comment with the link.

## What NOT to do

- Do not buy upvotes / use vote rings. HN detects and shadowbans for this. Ditto for Reddit.
- Do not post to Product Hunt yet — your one launch slot is precious. Wait until you have:
  – A signed/notarized build (no Gatekeeper warning).
  – A landing page with a clean screenshot above the fold.
  – A 30-second demo video (a GIF won't cut it for PH).
- Do not DM the link to specific people unsolicited. Sharing publicly is fine.
