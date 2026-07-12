# ADR-0004: Support all system Live Activity presentations

## Status

Accepted

## Context

The reference image resembles a wide Dynamic Island presentation, but iOS controls whether a Live Activity appears in compact, expanded, or minimal form. The app can't pin the Dynamic Island in its expanded presentation.

## Decision

- Treat the compact presentation as the primary acceptance layout: app icon in the leading region and elapsed duration in the trailing region.
- In the expanded presentation, retain the reference composition with the icon on the left and elapsed duration on the right.
- In the minimal presentation, show only the recognizable app mark.
- On the Lock Screen, show the app mark, the name `FloatClock`, and elapsed duration.

## Consequences

- Visual QA must cover compact, expanded, minimal, and Lock Screen presentations.
- The design must tolerate system-selected widths and truncation behavior.
- Matching the reference image doesn't imply that the expanded presentation remains permanently visible.
