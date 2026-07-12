# 08 — Show FloatClock on the Lock Screen

**What to build:** A display-only Lock Screen Live Activity that communicates the FloatClock identity and elapsed duration, and returns the user to the app's only switch when tapped.

**Blocked by:** 03 — Stop FloatClock and reconcile actual state; 05 — Deliver the brand and compact presentation.

**Mode:** AFK

**Status:** resolved

- [x] The Lock Screen presentation shows the FloatClock mark, the name `FloatClock`, and system elapsed duration.
- [x] Time uses white monospaced system typography and remains legible within representative Lock Screen widths.
- [x] Tapping the Live Activity opens the FloatClock app and presents the one-toggle main screen.
- [x] The Lock Screen presentation has no direct close control, button, toggle, App Intent, or other custom action.
- [x] SwiftUI previews cover representative times and system appearances.

## Result

The Lock Screen `.content` presentation now uses a reusable `FloatClockLockScreenContent`: the `FloatClockMark` on the left, a small `FloatClock` name above the white monospaced system timer text, with a spacer so the composition tolerates representative widths (the duration keeps `lineLimit(1)` and `minimumScaleFactor(0.5)`). Tapping the activity relies on default Live Activity behavior to open the app, whose only screen is the single toggle; no close control, button, toggle, App Intent, or custom action is present. New SwiftUI previews render the Lock Screen composition at seconds, minutes, over-an-hour representative durations in dark appearance plus a light-appearance variant. Device build succeeds and all thirteen tests pass.

