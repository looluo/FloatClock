# ADR-0013: Keep the Live Activity display-only

## Status

Accepted

## Context

The reference contains only a brand mark and time, and the product defines the app's single toggle as its control surface. Adding an end button to expanded or Lock Screen presentations would create a second control path and require additional intent behavior.

## Decision

- Add no buttons, toggles, or custom actions to any Live Activity presentation.
- Tapping the Live Activity uses the system behavior to open FloatClock.
- End FloatClock only from the main-screen toggle or through iOS system controls.

## Consequences

- Compact, expanded, minimal, and Lock Screen layouts remain display-only.
- No App Intent is required for Live Activity interaction in version one.
- Users who tap the Live Activity need one additional tap on the app toggle to end it.
