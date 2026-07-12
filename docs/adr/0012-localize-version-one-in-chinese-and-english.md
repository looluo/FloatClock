# ADR-0012: Localize version one in Simplified Chinese and English

## Status

Accepted

## Context

The persistent interface contains little text, but alerts, Settings guidance, Lock Screen context, and accessibility descriptions still need a defined language policy.

## Decision

- Ship Simplified Chinese and English localizations in version one.
- Keep the product name `FloatClock` unchanged in both languages.
- Let system timer text localize its duration format; don't manually localize or assemble timer digits.
- Localize failure alerts, Settings guidance, accessibility descriptions, and any system-facing explanatory strings.

## Consequences

- All user-facing string literals must use localization resources.
- UI and accessibility checks cover both languages.
- Adding another language later doesn't require changing the time model or brand name.
