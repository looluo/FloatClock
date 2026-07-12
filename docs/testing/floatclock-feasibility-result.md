# FloatClock feasibility result

## Verdict

Failed. Stop complete product development under ADR-0014.

## Environment

- Device: iPhone 16 Pro (`iPhone17,1`)
- iOS: 26.5.2 (`23F84`)
- Debugger state: not provided
- Low Power Mode: not provided
- Implementation: `TimelineView(.periodic(from: .now, by: 1))` formats each supplied date as device-local `mm:ss`

## Minimal reproduction

1. Install and open FloatClock on the physical device.
2. Turn the FloatClock switch on.
3. Observe that the Dynamic Island doesn't show the time while the FloatClock app remains foregrounded.
4. Return to the Home Screen.
5. Observe that a correct `mm:ss` value appears once in the Dynamic Island and then remains completely static.

## Observed behavior

- Foreground app: no Dynamic Island time is visible.
- Home Screen: one initial current-time value is visible.
- Update cadence: no subsequent updates observed; failure is immediate.
- Maximum visible error: grows continuously after the initial static value.
- Fifteen-minute Home Screen result: not run because the once-per-second criterion already failed.
- Lock/wake result: not run because the primary gate already failed.
- Hour-boundary result: not run because a static value cannot satisfy rollover.

## Diagnosis

The time formatter isn't the failing component: deterministic tests verify zero-padding and `59:59` to `00:00`, and the physical device renders a correct initial value. Activity creation, attribute decoding, and extension registration also work because the Live Activity appears.

The failure occurs at the system rendering boundary. The Live Activity host renders the initial `TimelineView` value but doesn't honor its periodic schedule as a once-per-second Live Activity update source. This matches Apple's ActivityKit model: Live Activities don't use WidgetKit timeline updates; their dynamic content is updated by the containing app through ActivityKit or by ActivityKit push notifications. SwiftUI also reserves the right to reduce a `TimelineView` cadence below the requested schedule.

## Product decision required

No code-only fix preserves every accepted constraint. Before implementation resumes, choose and document a new direction:

1. Change FloatClock semantics to a system-supported duration display, which can use system timer text but is no longer current local wall-clock `mm:ss`; or
2. Reopen the fully-local architecture decision and investigate remote ActivityKit updates, recognizing that ActivityKit notification budgets don't promise one update per second.

Don't approximate the clock, silently change its semantics, add server infrastructure, or misuse background execution without a new accepted decision.
