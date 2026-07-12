# ADR-0009: Use system visuals with one brand accent

## Status

Accepted

## Context

The reference image uses white clock digits on the system's black Dynamic Island and a pink-red alarm icon. The removed tenths digit was the only red part of the time string.

## Decision

- Render elapsed duration as white system timer text with monospaced digits and system-selected duration formatting.
- Don't color any time digit red after removing tenths-of-a-second precision.
- Use one shared pink-red brand accent for the original clock mark and the main-screen toggle tint.
- Let the Dynamic Island provide its own black shape; don't draw a competing pill background.
- Use the system app background and support light and dark appearance automatically.
- Add no decorative content to the main screen.

## Consequences

- The layout remains legible and stable across system appearances.
- Asset work is limited to the original brand mark and App Icon variants.
- Snapshot tests can focus on typography, spacing, truncation, and the shared accent color.
