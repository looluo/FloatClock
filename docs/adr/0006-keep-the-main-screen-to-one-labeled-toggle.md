# ADR-0006: Keep the main screen to one labeled toggle

## Status

Accepted

## Context

The product calls for a main screen with only one switch. A completely unlabeled switch would be ambiguous and inaccessible, while Live Activity authorization and request failures still need user-facing feedback.

## Decision

- Make a centered `Toggle` labeled `FloatClock` the only persistent control and content on the main screen.
- Provide a meaningful VoiceOver label, value, and state.
- Use transient system alerts for authorization, start, and stop failures.
- Disable the toggle while a start or stop operation is in flight to prevent duplicate requests.
- Add no persistent title, explanation, secondary button, or status text.

## Consequences

- Error states are communicated without expanding the steady-state interface.
- UI tests must cover rapid repeated taps and accessibility semantics.
- The app needs a small asynchronous state machine even though the visible interface is a single toggle.
