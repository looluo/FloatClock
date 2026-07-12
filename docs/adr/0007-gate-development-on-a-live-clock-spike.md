# ADR-0007: Gate full development on a live-clock feasibility spike

## Status

Superseded by ADR-0015 after the gate failed

## Context

FloatClock needs current local wall-clock `mm:ss`, including rollover from `59:59` to `00:00`. System timer text reliably represents a duration, but wall-clock minute rollover requires the view to recalculate from the current date. SwiftUI offers `TimelineView`, while iOS remains free to reduce its cadence and Live Activities don't use ordinary WidgetKit timelines.

## Decision

Before building the complete product, implement a minimal Live Activity spike on a physical supported device. It passes only if it:

- displays the correct current local `mm:ss` once per second;
- remains correct for at least 15 minutes with the app backgrounded or the device locked;
- crosses an hour boundary from `59:59` to `00:00` correctly;
- uses no server push; and
- doesn't depend on continuous app background execution.

Do not proceed to the complete product until this gate passes. If it fails, return to product design and choose between duration semantics and remote ActivityKit updates.

## Consequences

- The riskiest platform assumption is tested before UI polish and asset production.
- Simulator or Xcode preview behavior isn't sufficient evidence.
- The spike must also be tested without an attached debugger because debugging can change scheduling behavior.
