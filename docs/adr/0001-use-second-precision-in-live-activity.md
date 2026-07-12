# ADR-0001: Use second precision in the Live Activity

## Status

Superseded by ADR-0018

## Context

The initial FloatClock concept displayed current local time as `mm:ss.S`. A Live Activity is rendered and scheduled by iOS rather than by a continuously running app view. ActivityKit doesn't provide a reliable contract for updating Dynamic Island content every tenth of a second after the app moves to the background or the device locks.

## Decision

Display FloatClock time as `mm:ss`, using system-driven timer rendering where possible. Do not promise or simulate a tenths-of-a-second digit in the Live Activity.

Superseded by ADR-0018: FloatClock must return to the original `mm:ss.S` current-time requirement.

## Consequences

- The displayed time remains reliable when the app is backgrounded or the device is locked.
- The implementation avoids ten ActivityKit content updates per second.
- The design intentionally differs from the reference image by omitting its final decimal digit.
- Acceptance tests verify minute and second rollover, not subsecond animation.
