# 04 — Handle permission failures and rapid input safely

**What to build:** A resilient one-toggle experience that explains unavailable or failed Live Activity operations, prevents conflicting requests, and always returns to actual FloatClock state.

**Blocked by:** 03 — Stop FloatClock and reconcile actual state.

**Mode:** AFK

**Status:** resolved

- [x] When Live Activities are unavailable or disabled, an on request leaves actual state off and presents a transient alert.
- [x] A failed FloatClock creation reconciles the toggle with ActivityKit and presents a transient alert.
- [x] A failed FloatClock end reconciles the toggle with ActivityKit and presents a transient alert.
- [x] The toggle is disabled while a start or stop operation is in flight.
- [x] Rapid repeated input cannot create duplicate activities or overlapping start and stop operations.
- [x] No failure adds persistent explanatory content or another control to the main screen.
- [x] Automated tests cover disabled authorization, create failure, end failure, reconciliation after failure, and rapid repeated input.

## Result

The controller now exposes an `isInFlight` flag and a transient `FloatClockFailure` reason (`.activitiesUnavailable`, `.startFailed`, `.stopFailed`). Disabled authorization, a throwing create, and a throwing end each surface a failure and reconcile the toggle with the ActivityKit boundary; the `stopAll` seam became `async throws` so end failures are observable. Operations are serialized by an in-flight guard that ignores rapid repeated requests while one is running, and the ActivityKit count guard still prevents duplicate starts. The main screen keeps its single toggle: it is disabled while an operation runs and presents one transient alert on failure, with no persistent added content. Five new controller tests cover disabled authorization, create failure, end failure, in-flight observation, and overlapping rapid input (using a gated fake). Device build succeeds and all thirteen tests pass.

