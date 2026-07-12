# Current time with tenths feasibility result

## Verdict

Failed. Stop release development under ADR-0014 and ADR-0018.

## Environment

- Device: iPhone 15 or later class, exact model not recorded in this session
- iOS: not recorded in this session
- Implementation: minimal Live Activity spike using `TimelineView(.periodic(from: .now, by: 0.1))` to render device-local `mm:ss.S`
- Observation context: Home Screen / Dynamic Island

## Minimal reproduction

1. Install and open the current FloatClock build.
2. Turn the FloatClock switch on.
3. Return to the Home Screen.
4. Observe the Dynamic Island.

## Observed behavior

- Initial render: a `mm:ss.S` current-time value appears.
- Home Screen update cadence: no subsequent updates observed.
- Failure mode: the value freezes after the initial render.
- Ten-second gate: failed.

## Diagnosis

This reproduces the earlier wall-clock Live Activity failure, now with tenths precision. The formatter and initial render work, but the Live Activity host does not honor `TimelineView` as a reliable periodic update source while the app is not foregrounding the view.

This is consistent with `docs/research/current-time-with-tenths-activitykit.md`: Apple documentation does not guarantee `TimelineView` cadence inside Live Activities, local ActivityKit updates require app runtime, and APNs Live Activity pushes are budgeted/throttled rather than a 10 Hz current-time mechanism.

## Product decision required

No currently implemented code-only local approach satisfies `mm:ss.S` current-time Live Activity behavior on the Home Screen. Before release development resumes, choose a new product direction:

1. Change the product requirement away from tenths-precision current time; or
2. Approve a non-local architecture investigation, recognizing that APNs Live Activity pushes are not documented to support 10 Hz and may still fail; or
3. Stop the product because the required Live Activity behavior is not supported by iOS.

Do not ship elapsed duration, a fake decimal digit, a frozen current-time display, or a hidden background-execution workaround.
