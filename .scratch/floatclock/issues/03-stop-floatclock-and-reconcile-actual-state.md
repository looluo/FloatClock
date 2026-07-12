# 03 — Stop FloatClock and reconcile actual state

**What to build:** A complete off-and-reconciliation path in which the main toggle reflects whether FloatClock actually exists, ends it immediately on request, and recovers accurately across app launches and external termination.

**Blocked by:** 02 — Start one FloatClock from the only switch.

**Mode:** AFK

**Status:** resolved

- [x] Turning the toggle off ends and immediately dismisses all FloatClock Live Activities owned by the app.
- [x] Unexpected duplicate FloatClock activities are all cleaned up by the off action.
- [x] Opening or returning to the app reconciles the toggle with zero, one, or multiple actual FloatClock activities.
- [x] If iOS or the user ends FloatClock outside the app, the toggle returns to off when the app next reconciles.
- [x] The app doesn't persist an “always on” preference and doesn't automatically restart an ended FloatClock.
- [x] Automated tests through the ActivityKit boundary cover successful stop, duplicate cleanup, launch reconciliation, and external termination.

## Result

The ActivityKit boundary now reports the actual FloatClock count and ends every active instance with immediate dismissal. The main screen reconciles at initialization, first appearance, and whenever its scene becomes active. Tests cover one and multiple stops, zero/one/three initial activities, and external termination without restart. Device build succeeds and all eight tests pass.
