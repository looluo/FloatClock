# 02 — Start one FloatClock from the only switch

**What to build:** The production main-screen path in which the only persistent control is a centered, labeled `FloatClock` toggle and turning it on creates at most one FloatClock through a thin ActivityKit system boundary.

**Blocked by:** 01 — Prove system elapsed-duration feasibility.

**Mode:** AFK

**Status:** resolved

- [x] The main screen contains one centered `Toggle` labeled `FloatClock` and no other persistent title, explanation, button, status, or decoration.
- [x] Turning the toggle on requests one FloatClock Live Activity when none exists.
- [x] Turning the toggle on while FloatClock already exists does not create a duplicate.
- [x] FloatClock is configured as an iOS Live Activity and remains fully local.
- [x] ActivityKit authorization, lookup, creation, and provisional ending sit behind one thin production system boundary; activity-state observation remains in ticket 03.
- [x] State-controller tests through a deterministic fake verify successful creation and duplicate prevention as external behavior.
- [x] The app and tests build successfully for the iOS 17 deployment target.

## Result

The provisional spike controller is replaced by a production `FloatClockController` using one injectable ActivityKit client boundary. Deterministic tests verify first start, repeated On input, and an already-active FloatClock. Device build succeeds and all four tests pass.
