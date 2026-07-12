# 10 — Pass physical-device release acceptance

**What to build:** A verified FloatClock release candidate that satisfies the complete SPEC on supported physical hardware and stops with evidence if the platform feasibility assumption regresses.

**Blocked by:** 03 — Stop FloatClock and reconcile actual state; 04 — Handle permission failures and rapid input safely; 05 — Deliver the brand and compact presentation; 06 — Support the expanded presentation; 07 — Support the minimal presentation; 08 — Show FloatClock on the Lock Screen; 09 — Localize and make FloatClock accessible; 13 — Prove iOS 18 TimeDataSource current-time feasibility.

**Mode:** HITL — completion requires physical-device, visual, localization, and VoiceOver verification.

**Status:** resolved

- [x] All automated builds and tests pass for the iOS 18 iPhone app and Widget Extension.
- [x] On an iPhone with Dynamic Island running iOS 18+, FloatClock `hh:mm:ss.S` current time appears and advances for at least 10 consecutive seconds on the Home Screen without freezing.
- [x] Compact (mark left + `hh:mm:ss.S` right), expanded (mark + `hh:mm:ss.S`), minimal (mark), and Lock Screen (mark + FloatClock + `hh:mm:ss.S`) presentations match their accepted content, styling, and no-control rules on the physical device.
- [x] On, off, actual-state reconciliation, failure recovery, and rapid-input behavior are verified.
- [x] Simplified Chinese, English, and VoiceOver experiences are verified on the release candidate.
- [x] The release candidate uses only the iOS 18 `TimeDataSource.currentDate` architecture and no unrelated background mode.
- [x] If the current-time-with-tenths feasibility gate fails, release stops and the ADR-0014 evidence report is produced before any changed semantic or architecture is considered.

## Result

All release-acceptance items passed physical-device verification. The compact Dynamic Island displays `hh:mm:ss.S` at 12pt with `.frame(width: 66)` constraining the `TimeDataSource` oversized intrinsic; system clock and battery remain visible outside the island. Expanded, minimal, and Lock Screen presentations are correct. On/off toggle, reconciliation, failure alerts, rapid-input serialization, Simplified Chinese/English localization, and VoiceOver all verified on device. The app uses only `Text(.currentDate, format:)` with no background modes or APNs.
