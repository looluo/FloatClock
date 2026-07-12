# 01 — Prove system elapsed-duration feasibility

**What to build:** A minimal iOS 17 app and Live Activity that lets a person start FloatClock and verify that system timer text advances elapsed duration under the real scheduling conditions that gate the product.

**Blocked by:** None — can start immediately.

**Mode:** HITL — implementation can proceed independently, but passing requires physical-device observation.

**Status:** resolved

- [x] The minimal app builds for iPhone on iOS 17 and starts one FloatClock Live Activity on an iPhone 15 or later.
- [x] FloatClock captures one start anchor when the Live Activity begins and displays elapsed duration with system timer text.
- [x] On an iPhone 16 Pro, the Home Screen duration appears and visibly advances for at least 10 consecutive seconds.
- [x] The spike uses no backend, APNs updates, continuous app background execution, or unrelated background mode.
- [x] Rendering uses the original start anchor rather than creating a new anchor during view updates.

## Previous wall-clock spike result

Failed on iPhone 16 Pro running iOS 26.5.2. FloatClock doesn't show time in the Dynamic Island while its app is foregrounded. After returning to the Home Screen, the Dynamic Island shows one correct initial `mm:ss` value but never advances. The gate therefore fails immediately, before the 15-minute, lock/wake, or hour-boundary checks can produce meaningful pass results.

See `docs/testing/floatclock-feasibility-result.md`. ADR-0015 changes the product to elapsed duration; the revised gate above must now pass before blocked tickets continue.

## Revised implementation

Ready for physical-device verification. The Live Activity now stores one immutable start anchor and renders it with SwiftUI system timer text. The custom wall-clock formatter and `TimelineView` have been removed. Local iOS device build and start-anchor tests pass.

Physical verification confirms that elapsed duration appears and advances on an iPhone 16 Pro running iOS 26.5.2. ADR-0016 removes the three long-running checks, so the revised gate passes. See `docs/testing/floatclock-duration-result.md`.
