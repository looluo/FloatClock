# ADR-0003: Let each FloatClock activity run for the system-allowed lifetime

## Status

Accepted

## Context

FloatClock should remain useful after the app enters the background or the device locks. Live Activities are system-managed and can remain active for up to eight hours, but may end earlier because of user action, authorization changes, or system policy.

## Decision

- Request one FloatClock Live Activity when the user turns the main switch on.
- Keep it active for as long as the system permits, targeting the eight-hour Live Activity limit.
- Require acceptance tests to demonstrate at least 15 minutes of correct display while the app is backgrounded or the device is locked.
- Make the switch reflect whether a FloatClock Live Activity actually exists.
- When the switch is turned off, end and immediately dismiss all FloatClock Live Activities owned by the app.
- Don't automatically restart an activity after the system or user ends it.

## Consequences

- System-driven time rendering is required; the app must not depend on a continuously executing background timer.
- An activity ending before eight hours isn't automatically treated as an app defect unless it fails the 15-minute acceptance requirement under normal test conditions.
- Returning to the app reconciles the switch with ActivityKit's current activity list.
