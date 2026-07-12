# 12 — Investigate APNs-backed current-time-with-tenths updates

**What to build:** A high-risk feasibility spike that tests whether APNs Live Activity updates can remotely drive a `mm:ss.S` current-time display in the Dynamic Island for at least 10 seconds on a physical iPhone.

**Blocked by:** 11 — Prove current-time-with-tenths feasibility; ADR-0019 — Investigate APNs-backed current time with tenths.

**Mode:** HITL — completion requires Apple Developer/APNs setup, a reachable update sender, and physical-device observation.

**Status:** failed-superseded-by-ios18-timedatasource-spike

- [ ] Define the minimal APNs-backed architecture: app starts a Live Activity with `pushType: .token`, captures the push token, sends or exposes it to the spike sender, and a sender issues `liveactivity` update pushes.
- [ ] Decide how the spike sender computes `mm:ss.S`: device-local time cannot be known exactly from a remote server without time-zone/clock-skew assumptions, so the spike must explicitly document the approximation or transmit a display string only as a transport test.
- [ ] Implement the smallest app-side token capture and content-state update model needed for the spike.
- [ ] Implement or document a minimal APNs sender using project-approved credentials and environment.
- [x] Run on a supported physical iPhone, return to the Home Screen, and attempt at least 10 seconds of `mm:ss.S` updates.
- [x] Record observed cadence, latency, throttling, dropped pushes, failure time, device model, iOS version, Low Power Mode, Live Activity authorization, and `frequentPushesEnabled` state.
- [x] If APNs cannot sustain the required cadence, stop release development and document that no known architecture satisfies the requirement.
- [ ] If APNs appears to sustain the cadence, document backend/network/permission/user-setting risks before considering it a release candidate.

## Risk Notes

Official Apple documentation does not promise 10 Hz Live Activity push delivery. This ticket is a feasibility investigation, not an implementation commitment.

## Result

The physical-device APNs investigation failed. On the Home Screen, Dynamic Island updates arrived at intervals greater than 5 seconds and froze after roughly two visible updates. This fails the `mm:ss.S` current-time gate. Evidence is recorded in `docs/testing/apns-current-time-with-tenths-feasibility-result.md`. Release development remains blocked because no known architecture satisfies the current requirement.

## Superseded Follow-Up

`docs/research/dynamic-island-system-clock.md` identified iOS 18 `TimeDataSource.currentDate`, which is independent of APNs. ADR-0020 reopens feasibility for that mechanism only.
