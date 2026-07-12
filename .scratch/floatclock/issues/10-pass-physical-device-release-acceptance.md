# 10 — Pass physical-device release acceptance

**What to build:** A verified FloatClock release candidate that satisfies the complete SPEC on supported physical hardware and stops with evidence if the platform feasibility assumption regresses.

**Blocked by:** 03 — Stop FloatClock and reconcile actual state; 04 — Handle permission failures and rapid input safely; 05 — Deliver the brand and compact presentation; 06 — Support the expanded presentation; 07 — Support the minimal presentation; 08 — Show FloatClock on the Lock Screen; 09 — Localize and make FloatClock accessible; 13 — Prove iOS 18 TimeDataSource current-time feasibility.

**Mode:** HITL — completion requires physical-device, visual, localization, and VoiceOver verification.

**Status:** ready-for-agent

- [ ] All automated builds and tests pass for the iOS 18 iPhone app and Widget Extension.
- [ ] On an iPhone with Dynamic Island running iOS 18+, FloatClock `mm:ss.S` current time appears and advances for at least 10 consecutive seconds on the Home Screen without freezing.
- [ ] Compact (mark left + `mm:ss.S` right), expanded (mark + `hh:mm:ss.S`), minimal (mark), and Lock Screen (mark + FloatClock + `hh:mm:ss.S`) presentations match their accepted content, styling, and no-control rules on the physical device.
- [ ] On, off, actual-state reconciliation, failure recovery, and rapid-input behavior are verified.
- [ ] Simplified Chinese, English, and VoiceOver experiences are verified on the release candidate.
- [ ] The release candidate uses only the iOS 18 `TimeDataSource.currentDate` architecture and no unrelated background mode.
- [ ] If the current-time-with-tenths feasibility gate fails, release stops and the ADR-0014 evidence report is produced before any changed semantic or architecture is considered.

## Blocker

HITL review rejected the elapsed-duration semantics implemented under ADR-0015 and restored the original current-time-with-tenths requirement under ADR-0018. The pure-local `TimelineView` `mm:ss.S` spike failed on a physical device by freezing after its initial render. The APNs-backed investigation in ticket 12 also failed: Home Screen updates were greater than 5 seconds apart and froze after roughly two visible updates. ADR-0020 reopened feasibility for iOS 18 `TimeDataSource.currentDate`; ticket 13 passed the primary Home Screen Dynamic Island gate with 2 minutes of continuous tenths updates. Release acceptance may proceed with full presentation, localization, VoiceOver, and device-state verification.
