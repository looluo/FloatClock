# 06 — Support the expanded presentation

**What to build:** An expanded Dynamic Island presentation that preserves FloatClock's reference composition and remains legible within system-selected dimensions.

**Blocked by:** 05 — Deliver the brand and compact presentation.

**Mode:** AFK

**Status:** resolved

- [x] The expanded presentation places the FloatClock mark on the left and system elapsed duration on the right.
- [x] Time uses the same white monospaced system typography as the compact presentation.
- [x] The layout remains legible and avoids truncating the mark or time across representative system widths.
- [x] The presentation contains no button, toggle, custom action, or additional pill background.
- [x] SwiftUI previews demonstrate representative times in light and dark appearance.
- [x] The implementation doesn't attempt to keep the Dynamic Island permanently expanded.

## Result

The expanded `DynamicIslandExpandedRegion` pair keeps the `FloatClockMark` in the leading region and `FloatClockDurationText` in the trailing region, reusing the compact presentation's white monospaced system timer text. The duration text now sets `lineLimit(1)` and `minimumScaleFactor(0.5)` so a growing hour-component value stays on one line and scales rather than truncating within system-selected widths. The region contains no buttons, toggles, custom actions, or competing pill background, and nothing pins the island expanded. New SwiftUI previews render the expanded composition (mark left, time right) at representative elapsed durations (seconds, minutes, over an hour) in both light and dark appearance. Device build succeeds and all thirteen tests pass.

