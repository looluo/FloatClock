# FloatClock Domain Context

## Glossary

### FloatClock

An active Live Activity that presents the device-local current system time with tenths precision.

- The display target is the device's current wall-clock time: `mm:ss.S` in the compact Dynamic Island trailing region (the system status bar clock outside the island provides `hh:mm`); `hh:mm:ss.S` in expanded and Lock Screen presentations.
- The time display uses iOS 18 `Text(.currentDate, format:)` with `TimeDataSource`, which updates continuously without app runtime.
- A pure local `TimelineView` implementation failed physical-device feasibility because the Dynamic Island rendered one wall-clock value and then stopped updating; `Text(.currentDate, format:)` does not have this problem.
- Elapsed duration from the switch-on moment is no longer accepted product behavior.
- The compact trailing `Text(.currentDate, format:)` requires `.frame(width:)` because `TimeDataSource` reports an intrinsic size larger than its visible glyphs.

### FloatClock state

The app-level state that indicates whether the FloatClock Live Activity should be active. The main-screen switch requests this state to be on or off; it is not itself the source of truth for whether iOS currently has an active Live Activity.

## Avoided terms

- Do not describe FloatClock as elapsed duration.
- Do not describe FloatClock as a timer that starts from zero when turned on.
