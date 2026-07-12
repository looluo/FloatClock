# 13 — Prove iOS 18 TimeDataSource current-time feasibility

**What to build:** A focused iOS 18+ physical-device spike that tests whether `TimeDataSource.currentDate` can keep FloatClock's `mm:ss.S` current time advancing in the Dynamic Island without `TimelineView`, APNs, background modes, or app-side timer updates.

**Blocked by:** ADR-0020 — Spike iOS 18 TimeDataSource current time.

**Mode:** HITL — completion requires physical-device observation on an iPhone with Dynamic Island running iOS 18 or later.

**Status:** resolved

- [x] Raise the spike deployment target to iOS 18.
- [x] Replace the failed `TimelineView(.periodic(..., 0.1))` text with `Text(.currentDate, format: Date.FormatStyle().minute(.twoDigits).second(.twoDigits).secondFraction(.fractional(1)))`.
- [x] Keep the existing ActivityKit lifecycle, one-toggle UI, mark, layout, permission handling, localization, and stop/reconciliation paths intact.
- [x] Avoid APNs, background modes, and app-side timer updates.
- [x] Run on a physical iPhone with Dynamic Island, return to the Home Screen, and observe `mm:ss.S` for at least 10 consecutive seconds.
- [x] Record whether the display updates at tenths cadence, degrades to seconds, freezes after one render, freezes later, or only updates while the app is foregrounded.
- [x] If the gate passes, record the device model, iOS version, observed cadence, and any skipped/degraded frames; then continue visual polish such as pink-red decimal styling.
- [ ] If the gate fails, record evidence and stop this architecture path.

## Implementation State

The project deployment target is now iOS 18. `FloatClockCurrentTimeText` uses `TimeDataSource.currentDate` with a Foundation `Date.FormatStyle` containing minute, second, and one fractional second digit. Device build succeeds and all seventeen automated tests pass. For this spike, the entire time string is white; the pink-red final tenths digit remains a post-feasibility visual refinement.

## Result

The iOS 18 `TimeDataSource.currentDate` spike passed the primary physical-device Home Screen gate: the Dynamic Island displayed current system time, updated continuously at tenths precision, and did not freeze after 2 minutes. Evidence is recorded in `docs/testing/ios18-timedatasource-current-time-result.md`. Follow-up visual fixes removed extra compact trailing width and colored the final tenths digit with the brand accent.
