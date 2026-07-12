# 11 — Prove current-time-with-tenths feasibility

**What to build:** A minimal physical-device spike that tests whether FloatClock can display device-local current time as `mm:ss.S` in a Live Activity without freezing on the Home Screen.

**Blocked by:** ADR-0018 — Restore current time with tenths.

**Mode:** HITL — completion requires physical-device observation on an iPhone 15 or later.

**Status:** superseded-by-ios18-timedatasource-spike

- [x] Implement the smallest possible Live Activity spike that renders device-local `mm:ss.S` current time.
- [x] The spike must not use elapsed duration, a fake decimal digit, unrelated background modes, or hidden persistent app UI.
- [x] Prefer a minimal `TimelineView(.periodic(from:by: 0.1))` or equivalent SwiftUI date-rendering experiment only as a feasibility test, not as a committed architecture.
- [x] Run on a supported physical iPhone, return to the Home Screen, and observe Dynamic Island behavior for at least 10 consecutive seconds.
- [x] Record whether the display updates at tenths cadence, degrades to seconds, freezes after one render, or updates only while the app is foregrounded.
- [x] If the gate fails, stop release development and produce an evidence report with device model, iOS version, observed cadence, time to failure, Home Screen behavior, Lock Screen behavior, and minimal reproduction code.
- [ ] If the gate passes, record evidence and still flag that Apple documentation does not guarantee this cadence in Live Activities.

## Research Basis

See `docs/research/current-time-with-tenths-activitykit.md`. Official Apple documentation does not provide a supported architecture for reliable 10 Hz Live Activity updates while the app is backgrounded. APNs Live Activity pushes are budgeted and throttled, local ActivityKit updates require app runtime, and `TimelineView` cadence may be slower than requested.

## Implementation State

The spike removes the start-anchor model from `FloatClockAttributes` and the ActivityKit client seam. The Live Activity renders `FloatClockCurrentTimeText`, which uses `TimelineView(.periodic(from: .now, by: 0.1))` and `FloatClockCurrentTimeFormatter` to display device-local `mm:ss.S`. The `mm:ss` portion is white monospaced text and the `.S` suffix uses the pink-red brand accent, matching the reference concept. The implementation intentionally remains a feasibility spike because Apple documentation does not guarantee this cadence in Live Activities. Device build succeeds and all seventeen automated tests pass.

## Physical-Device Instructions

1. Install and launch the current build on an iPhone 15 or later.
2. Turn FloatClock on.
3. Return to the Home Screen.
4. Observe the Dynamic Island for at least 10 consecutive seconds.
5. Record whether `mm:ss.S` updates at tenths cadence, only at second cadence, freezes after one render, or only updates while the app is foregrounded.

## Result

The physical-device HITL observation failed: `mm:ss.S` appeared on the initial Dynamic Island render and then froze. This fails the 10-second Home Screen gate. Evidence is recorded in `docs/testing/current-time-with-tenths-feasibility-result.md`. Release development remains blocked.

## Superseded Follow-Up

`docs/research/dynamic-island-system-clock.md` identified a new iOS 18 `TimeDataSource.currentDate` path that was not tested by this `TimelineView` spike. ADR-0020 reopens feasibility only for that new mechanism.
