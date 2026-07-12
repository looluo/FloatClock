# APNs current time with tenths feasibility result

## Verdict

Failed. APNs-backed Live Activity updates do not satisfy the FloatClock `mm:ss.S` requirement under the observed physical-device conditions.

## Environment

- Device: iPhone 15 or later class, exact model not recorded in this session
- iOS: not recorded in this session
- Implementation: APNs-backed Live Activity update investigation under ADR-0019
- Observation context: Home Screen / Dynamic Island

## Minimal reproduction

1. Start FloatClock as a Live Activity capable of receiving remote `liveactivity` updates.
2. Return to the Home Screen.
3. Send APNs Live Activity update pushes intended to advance the displayed current time.
4. Observe Dynamic Island behavior.

## Observed behavior

- Home Screen update interval: very large, greater than 5 seconds.
- Number of visible updates before failure: approximately 2.
- Failure mode: display freezes after the second observed update.
- Ten-second `mm:ss.S` gate: failed.

## Diagnosis

The APNs-backed path does not provide the cadence or continuity required for FloatClock. The observed update interval is far slower than 10 Hz and eventually freezes. This matches the risk documented in `docs/research/current-time-with-tenths-activitykit.md`: APNs Live Activity updates are budgeted, may be throttled, and are not documented as a near-real-time per-device clock transport.

## Product decision required

After both the local `TimelineView` spike and APNs-backed investigation failed, there is no known architecture in this project that satisfies device-local current time with tenths precision (`mm:ss.S`) in a Live Activity on the Home Screen.

Before release development resumes, choose one:

1. Stop the product because the required Live Activity behavior is not supported by observed iOS behavior.
2. Change the product requirement to a supported display that does not need continuous current-time tenths in the Live Activity.
3. Define a new external architecture hypothesis with explicit evidence for why it could overcome both observed failures.

Do not ship elapsed duration, a fake decimal digit, a frozen clock, or hidden background-execution workarounds.
