# ADR-0005: Use an original clock mark

## Status

Accepted

## Context

The reference uses a pink-red rounded-square icon with a white alarm-clock glyph. SF Symbols are suitable for interface controls but their terms prohibit using symbols, or confusingly similar images, as app icons or logos.

## Decision

- Create an original alarm-clock mark inspired by the reference's concept and palette, not a direct copy of an SF Symbol.
- Use the full-color mark for the App Icon.
- Derive a simplified, small-size-safe version of the same mark for the Dynamic Island.
- Preserve high contrast and recognizability at compact and minimal Live Activity sizes.

## Consequences

- Icon work requires an original source asset and exported App Icon variants.
- Visual QA must verify the mark at App Icon, compact, and minimal sizes.
- An SF Symbol may still be used for ordinary interface semantics where its license permits, but not as the FloatClock brand mark.
