# ADR-0020: Spike iOS 18 TimeDataSource current time

## Status

Accepted for spike

## Context

The local `TimelineView` spike and APNs-backed investigation failed to keep `mm:ss.S` current time updating in the Dynamic Island. A later research pass found an untested Apple-supported mechanism introduced in iOS 18: `TimeDataSource.currentDate` with `Text(_:format:)` and `Date.FormatStyle` conforming to `DiscreteFormatStyle`.

Apple documents `TimeDataSource` as supplying live automatically updating values to `Text` in Widgets, Live Activities, watchOS complications, and apps. This mechanism was not covered by the failed `TimelineView` or APNs investigations.

See `docs/research/dynamic-island-system-clock.md`.

## Decision

- Restart development as a focused iOS 18+ physical-device spike.
- Raise the product minimum deployment target to iOS 18 for this spike.
- Replace the failed `TimelineView(.periodic(..., 0.1))` text with `Text(.currentDate, format: Date.FormatStyle().minute(.twoDigits).second(.twoDigits).secondFraction(.fractional(1)))`.
- Keep the existing ActivityKit lifecycle, mark, layout, permission, localization, and stop/reconciliation work intact.
- Do not add APNs, background modes, or app-side timer updates for this spike.

## Consequences

- iOS 17 support is no longer part of the current feasibility path.
- API availability is promising but not sufficient; physical-device Dynamic Island verification is still required.
- If this spike freezes or degrades below acceptable cadence, no currently documented project architecture remains for the `mm:ss.S` requirement.
