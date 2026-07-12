# ADR-0017: Return to device-local current time

## Status

Superseded by ADR-0018

## Context

ADR-0015 changed FloatClock from device-local current time to elapsed duration because the first physical-device spike showed that a Live Activity rendered a `TimelineView` wall-clock value once and then stopped updating. The elapsed-duration implementation proved technically feasible because SwiftUI system timer text is updated by iOS.

During HITL review, the product owner rejected elapsed duration because FloatClock must show the device's current system time, not a count from when the switch was turned on. The product owner also rejected the current Dynamic Island layout as not matching the reference composition.

## Decision

- Redefine FloatClock as an active Live Activity that presents the device-local current system time.
- ADR-0015 is superseded. FloatClock must not ship as an elapsed-duration counter.
- The display target is the current minute and second of the device-local wall clock, matching the reference's time concept and omitting the removed decimal digit.
- Superseded by ADR-0018: the decimal tenths digit is restored and required.
- Do not silently reintroduce the previous pure-local `TimelineView` implementation as the release solution, because the physical-device spike showed it becomes static in the Dynamic Island.
- Full release development is blocked until a new current-time update architecture is selected and proven on a physical device.
- Candidate architectures must be explicitly approved before implementation, such as ActivityKit push updates with an APNs-capable backend or another system-supported mechanism. The app still must not misuse unrelated background modes.

## Consequences

- Existing code that stores `startDate` and renders `Text(startDate, style: .timer)` is now semantically wrong even though it is technically functional.
- Tickets and specs that mention elapsed duration, fixed start anchors, system timer text owning progression, or the 10-second elapsed-duration smoke gate are superseded.
- The prior wall-clock feasibility failure remains valid evidence; new work must either solve that failure with a new architecture or stop with updated evidence.
- Dynamic Island layout work can continue only insofar as it is independent of the time update architecture.
