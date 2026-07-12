# FloatClock elapsed-duration feasibility result

## Status

Passed under ADR-0016.

## Environment

- Device: iPhone 16 Pro (`iPhone17,1`)
- iOS: 26.5.2 (`23F84`)
- Rendering: SwiftUI system timer text anchored to the FloatClock start date

## Confirmed

- FloatClock appears in the Dynamic Island after returning to the Home Screen.
- Elapsed duration starts from the On action.
- The displayed duration advances rather than remaining static.
- A supplied Home Screen screenshot shows the activity at `0:13`.

## Acceptance

The product owner removed the 15-minute Home Screen, 15-minute lock/wake, and one-hour boundary gates. The observed advancing duration and supplied screenshot satisfy the replacement 10-second smoke criterion. Ticket 01 is resolved.
