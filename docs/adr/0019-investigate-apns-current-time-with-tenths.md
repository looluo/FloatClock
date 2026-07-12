# ADR-0019: Investigate APNs-backed current time with tenths

## Status

Accepted for investigation

## Context

ADR-0018 restored the original product requirement: FloatClock must display device-local current system time with tenths precision (`mm:ss.S`) in the Dynamic Island. The local `TimelineView(.periodic(from:by: 0.1))` feasibility spike failed on a physical device: the value rendered once and froze.

Apple documentation does not provide a supported architecture for reliable 10 Hz Live Activity updates while the app is backgrounded. APNs Live Activity pushes are documented as budgeted and throttleable, and frequent-update support is framed as many updates per minute rather than many updates per second. See `docs/research/current-time-with-tenths-activitykit.md`.

The product owner selected the non-local architecture investigation path after the local spike failed.

## Decision

- Investigate an APNs-backed ActivityKit update architecture as a feasibility spike only.
- The spike must test whether remote Live Activity updates can keep a `mm:ss.S` display advancing on a physical iPhone Home Screen for at least 10 seconds.
- The spike must record cadence, latency, throttling, delivery failure, device state, iOS version, app authorization state, and whether `frequentPushesEnabled` is available/enabled.
- The spike must not be treated as a release architecture unless physical-device evidence and operational constraints are acceptable.
- Do not hide the backend/network dependency if this path is pursued; the original fully-local constraint is superseded only for this investigation.
- Do not misuse unrelated background modes.

## Consequences

- Version-one fully-local assumptions are suspended for this investigation only.
- A working spike would introduce backend, APNs credential, network, and operational reliability considerations.
- A failed spike means no known architecture remains for `mm:ss.S` in a Live Activity under the current product requirement.
