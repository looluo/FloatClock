# ADR-0014: Stop if the feasibility gate fails

## Status

Accepted

## Context

The product depends on an iOS behavior that official documentation doesn't guarantee: recalculating device-local wall-clock time once per second in a backgrounded Live Activity. Continuing after a failed spike would require changing product semantics or expanding the architecture.

## Decision

If the physical-device feasibility spike fails, stop complete product development and report:

- device model and iOS version;
- observed refresh cadence and time to failure;
- Home Screen, Lock Screen, and hour-boundary behavior;
- minimal reproduction code; and
- the two explicit product alternatives: duration semantics or a separately approved APNs-backed architecture.

Don't silently show approximate time, fake refreshes, add remote infrastructure, or misuse background modes such as silent audio to keep the process alive.

## Consequences

- Product approval is required before work resumes on a changed semantic or architecture.
- The implementation remains honest about platform capabilities and App Store constraints.
- Spike evidence becomes the basis for the next decision instead of sunk-cost pressure.
