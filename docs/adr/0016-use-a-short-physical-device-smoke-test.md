# ADR-0016: Use a short physical-device smoke test

## Status

Accepted

## Context

The elapsed-duration implementation uses SwiftUI system timer text, and an iPhone 16 Pro running iOS 26.5.2 has shown that it appears in the Dynamic Island and advances. The earlier acceptance plan required separate 15-minute Home Screen, 15-minute lock/wake, and one-hour boundary observations. The product owner explicitly removed those three long-running gates to continue development.

## Decision

- Accept the elapsed-duration feasibility gate when a supported physical device shows the Live Activity and its duration advances for at least 10 consecutive seconds on the Home Screen.
- Don't require a 15-minute Home Screen observation, a 15-minute lock/wake observation, or a one-hour duration-boundary observation for ticket 01 or release acceptance.
- Keep system-owned duration behavior and formatting; don't replace it with custom periodic rendering.

## Consequences

- Ticket 01 passes based on the iPhone 16 Pro observation and supplied screenshot.
- Longer-duration, lock/wake, and hour-boundary behavior aren't release guarantees.
- Dependent implementation tickets may proceed.
