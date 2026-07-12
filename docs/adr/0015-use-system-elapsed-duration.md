# ADR-0015: Use system elapsed duration

## Status

Superseded by ADR-0017

## Context

The physical-device feasibility spike for device-local wall-clock `mm:ss` failed on an iPhone 16 Pro running iOS 26.5.2. The Live Activity rendered the `TimelineView` value once and didn't honor periodic redraws. ActivityKit doesn't use WidgetKit timelines to update Live Activity content.

SwiftUI provides system timer text that iOS updates without running the app or repeatedly updating ActivityKit content. It represents duration relative to a fixed date, not current wall-clock minute and second.

## Decision

- Redefine FloatClock as elapsed duration since the person turns it on.
- Capture one start date when requesting the Live Activity and include it in the activity's immutable attributes.
- Render that date using SwiftUI system timer text in every presentation.
- Remove `TimelineView` and custom current-time formatting from the Live Activity.
- Accept the system's duration formatting. Don't require a leading zero for minutes or a fixed `mm:ss` shape after one hour.
- Duration continues across hour boundaries rather than resetting.
- Keep the app fully local and verify system timer text with the short physical-device smoke test in ADR-0016.

## Consequences

- FloatClock no longer displays the device's current local wall-clock minute and second.
- The timer can advance while the app is suspended because iOS owns the text update.
- Superseded by ADR-0017 after HITL review rejected elapsed-duration semantics.
- This ADR remains as implementation evidence for why elapsed duration was technically feasible, but it is no longer the product definition.
