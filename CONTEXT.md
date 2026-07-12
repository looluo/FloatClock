# FloatClock Domain Context

## Glossary

### FloatClock

An active Live Activity that presents the device-local current system time with tenths precision.

- The display target is the device's current wall-clock minute, second, and one tenths digit: `mm:ss.S`.
- A pure local `TimelineView` implementation failed physical-device feasibility because the Dynamic Island rendered one wall-clock value and then stopped updating.
- Elapsed duration from the switch-on moment is no longer accepted product behavior.
- Full release development is blocked until a current-time-with-tenths update architecture is selected and proven on a physical device.

### FloatClock state

The app-level state that indicates whether the FloatClock Live Activity should be active. The main-screen switch requests this state to be on or off; it is not itself the source of truth for whether iOS currently has an active Live Activity.

## Avoided terms

- Do not describe FloatClock as elapsed duration.
- Do not describe FloatClock as a timer that starts from zero when turned on.
