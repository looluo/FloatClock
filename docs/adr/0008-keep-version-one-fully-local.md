# ADR-0008: Keep version one fully local

## Status

Accepted

## Context

FloatClock displays a device-local elapsed duration and doesn't require remote data. A push-notification service would substantially increase operational, privacy, and failure complexity for a one-control utility.

## Decision

- Version one has no account system, backend, analytics dependency, ActivityKit push notifications, or required network connection.
- Derive duration exclusively from the locally captured start anchor and system timer text.
- Treat failure of the local feasibility gate as a product-design blocker rather than silently adding remote infrastructure.

## Consequences

- The app remains useful offline and has no server operating cost.
- ActivityKit content must be correct using only system-local rendering and scheduling behavior.
- A future backend would require a new ADR and explicit product approval.
