# ADR-0011: Use a native SwiftUI and ActivityKit stack

## Status

Accepted

## Context

The app has one persistent control and one Live Activity. Both the app interface and WidgetKit presentation can use SwiftUI, while ActivityKit owns the Live Activity lifecycle.

## Decision

- Use the SwiftUI app lifecycle for the iPhone app target.
- Build the Live Activity in a Widget Extension with SwiftUI and WidgetKit.
- Use ActivityKit for authorization, reconciliation, creation, observation, and ending.
- Use Swift Concurrency with `async`/`await`; isolate UI-observable state to the main actor.
- Add no UIKit layer, third-party UI library, or external state-management framework.

## Consequences

- Shared presentation helpers and Activity attributes can remain small and native.
- The project needs both an app target and a Widget Extension target.
- Tests can isolate time formatting and lifecycle state transitions without introducing another architecture framework.
