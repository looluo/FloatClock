# ADR-0018: Restore current time with tenths

## Status

Accepted

## Context

HITL review rejected the elapsed-duration implementation and then clarified that FloatClock must return to the original reference concept: the device-local current system time, including one digit after the seconds decimal point.

Earlier decisions removed tenths precision and later switched to elapsed duration because ActivityKit did not reliably honor a pure-local `TimelineView` update schedule in the Dynamic Island. That feasibility evidence still stands: the previous wall-clock implementation rendered one correct value and then froze on the Home Screen.

## Decision

- FloatClock must display the device-local current system time with minute, second, and one tenths digit: `mm:ss.S`.
- ADR-0001, ADR-0015, and ADR-0017 are superseded wherever they remove the decimal digit, accept elapsed duration, or define the display as only minute and second.
- The final decimal digit is part of the product requirement, not optional visual polish.
- Do not implement or ship a fake decimal digit, an elapsed-duration counter, or a current-time display that freezes after its initial render.
- Full release development remains blocked until an architecture can prove this current-time-with-tenths display on a physical device in the Dynamic Island.

## Consequences

- The current `Text(startDate, style: .timer)` implementation is doubly wrong: it shows elapsed duration and cannot represent device-local wall-clock tenths.
- A pure local `TimelineView(.periodic(..., by: 0.1))` is not an accepted release solution unless a new physical-device spike proves it now updates reliably in the Live Activity host.
- Candidate architectures likely require frequent ActivityKit content updates and must be evaluated against iOS update budgets, latency, background execution rules, and APNs/backend implications.
- Acceptance must include observing `mm:ss.S` advancing on a supported physical device without freezing.
