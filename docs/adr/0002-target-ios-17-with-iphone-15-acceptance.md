# ADR-0002: Target iOS 17 with iPhone 15-and-later acceptance

## Status

Accepted

## Context

The product only needs validation on iPhone 15 and later. Xcode deployment targets constrain operating-system versions rather than device generations, and older iPhone 14 Pro models also provide a Dynamic Island.

## Decision

- Set the minimum deployment target to iOS 17.
- Define the supported acceptance-test matrix as iPhone 15 series and later.
- Do not add a device-model allowlist or deliberately block compatible older devices.
- Build an iPhone-only app; iPad is outside the acceptance scope.

## Consequences

- The implementation can use APIs available in iOS 17 without compatibility branches for iOS 16.
- Compatible iPhone 14 Pro devices may run the app, but they are not part of the required QA matrix.
- New iPhone models don't require allowlist maintenance.
