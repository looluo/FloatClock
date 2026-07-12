# ADR-0010: Define the background clock acceptance test

## Status

Superseded by ADR-0016

## Context

“Remain active in the background for at least 15 minutes” is ambiguous across screen-off, Always-On Display, Low Power Mode, debugger attachment, and system scheduling conditions.

## Decision

Use this reproducible acceptance procedure:

1. Run on a physical iPhone 15 or later without an attached Xcode debugger.
2. Use sufficient battery charge with Low Power Mode disabled.
3. Start FloatClock, return to the Home Screen, and keep the display awake for 15 minutes.
4. Verify the elapsed duration advances once per second with no more than one second of visible error.
5. Separately lock the device for 15 minutes, wake it, and verify that the visible time is immediately correct. Don't require invisible screen-off content to render every intermediate frame.
6. Run at least one test across a one-hour duration boundary and verify the duration continues without resetting; the system may add an hour component.

## Consequences

- The same procedure gates the feasibility spike and final release acceptance.
- Simulator, preview, and debugger-attached results remain useful diagnostics but don't satisfy acceptance.
- Low Power Mode behavior is outside the initial hard guarantee and can be characterized separately.
