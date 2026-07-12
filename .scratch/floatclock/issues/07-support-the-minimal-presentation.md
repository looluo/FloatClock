# 07 — Support the minimal presentation

**What to build:** A minimal Dynamic Island presentation that keeps FloatClock identifiable when iOS constrains the activity to its smallest form.

**Blocked by:** 05 — Deliver the brand and compact presentation.

**Mode:** AFK

**Status:** resolved

- [x] The minimal presentation contains only the simplified FloatClock mark.
- [x] The mark remains crisp, recognizable, and within the system's minimal-region bounds.
- [x] The presentation adds no time text, controls, custom actions, or competing background.
- [x] SwiftUI preview verifies the minimal presentation in its constrained size.
- [x] The implementation allows iOS to choose minimal, compact, or expanded presentation without attempting to pin one form.

## Result

The `minimal` Dynamic Island region contains only the simplified `FloatClockMark` at a constrained 18-point size with no time text, controls, custom actions, or competing background. The mark's stroke width has a 1.25-point floor so the clock face stays crisp inside the minimal region. Nothing pins a presentation form; iOS still selects minimal, compact, or expanded. A new SwiftUI preview renders the minimal mark clipped to the system's circular minimal bounds in both light and dark appearance. Device build succeeds and all thirteen tests pass.

