# FloatClock

Status: ready-for-release-acceptance

## Current Product Decision

ADR-0018 and ADR-0020 define the current architecture. FloatClock presents the device-local current system time with tenths precision using iOS 18 `Text(.currentDate, format:)` with `TimeDataSource`. The compact Dynamic Island shows `mm:ss.S` (the system status bar clock outside the island provides `hh:mm`); expanded and Lock Screen presentations show the full `hh:mm:ss.S`. The earlier `TimelineView` and APNs approaches both failed physical-device feasibility; the iOS 18 `TimeDataSource` path passed a 2-minute Home Screen gate without freezing. The compact trailing `Text(.currentDate, format:)` requires `.frame(width: 56)` because the `TimeDataSource` reports an intrinsic size larger than its visible glyphs, which otherwise expands the Dynamic Island and hides system status bar items.

## Problem Statement

An iPhone user wants to see the device-local current system time at a glance in the Dynamic Island without keeping an app in the foreground. The experience needs to be extremely simple to control, remain useful after FloatClock moves to the background, and stay visually consistent with the supplied reference design.

## Solution

Build an iPhone-only Swift app whose main screen contains one centered, labeled `FloatClock` toggle. Turning the toggle on requests one FloatClock Live Activity; turning it off ends and immediately removes all FloatClock Live Activities owned by the app. The toggle reflects actual ActivityKit state rather than a saved wish to remain on.

FloatClock displays the device-local current system time. The compact Dynamic Island shows `mm:ss.S` in the trailing region (the system status bar clock outside the island provides hours and minutes); expanded and Lock Screen presentations show the full `hh:mm:ss.S`. The Dynamic Island composition follows the reference: original FloatClock mark on the left (compactLeading) and current time on the right (compactTrailing). The Live Activity also supplies expanded, minimal, and Lock Screen presentations. It is display-only, and tapping it opens the app.

The current-time architecture was proven on a physical device: iOS 18 `Text(.currentDate, format: Date.FormatStyle().minute(.twoDigits).second(.twoDigits).secondFraction(.fractional(1)))` updates continuously at tenths cadence without freezing. The compact trailing text requires `.frame(width:)` to constrain the oversized intrinsic size reported by `TimeDataSource`.

## User Stories

1. As an iPhone user, I want to turn FloatClock on with one toggle, so that the device-local current time with tenths precision appears in the Dynamic Island.
2. As an iPhone user, I want to turn FloatClock off with the same toggle, so that the Live Activity is immediately removed.
3. As an iPhone user, I want the toggle to show whether FloatClock actually exists, so that the app never presents stale state.
4. As a returning user, I want the app to reconcile the toggle with ActivityKit when it opens, so that an existing FloatClock is shown as on.
5. As an iPhone user, I want only one FloatClock to be active, so that repeated input doesn't create duplicate Live Activities.
6. As an iPhone user, I want the toggle disabled while a start or stop request is in progress, so that rapid taps don't create conflicting operations.
7. As an iPhone user, I want a clear alert if FloatClock cannot start, so that I understand why the toggle returned to off.
8. As an iPhone user, I want a clear alert if Live Activities are disabled, so that I can decide whether to enable them in system settings.
9. As an iPhone user, I want a clear alert if FloatClock cannot stop, so that failure isn't hidden behind an incorrect toggle state.
10. As an iPhone user, I want FloatClock to show the current wall-clock minute, second, and one tenths digit, so that it matches the reference time concept.
11. As an iPhone user, I want current seconds and the tenths digit to advance while the app is backgrounded, so that the time remains useful on the Home Screen.
12. As an iPhone user, I want the selected architecture to prove physical-device current-time-with-tenths updates, so that FloatClock does not silently freeze after one rendered value.
13. As an iPhone user, I want the display to continue across minute and hour boundaries, so that it remains the current local time.
14. As a returning user, I want an existing FloatClock to continue showing current time rather than restarting from zero.
15. As an iPhone user, I want FloatClock to remain correct after the app moves to the background, so that I don't have to keep the app open.
16. As an iPhone user, I want FloatClock time to visibly advance on the Home Screen, so that I know it is active.
17. As an iPhone user, I want current-time background progression to use a proven supported architecture, so that the app does not rely on unsupported periodic rendering.
18. As an iPhone user, I want each FloatClock to remain active for as long as iOS permits, targeting the system's eight-hour Live Activity limit, so that I don't need to restart it frequently.
19. As an iPhone user, I want FloatClock to stop showing as on if iOS or I end the Live Activity, so that the app reflects reality.
20. As an iPhone user, I want a compact Dynamic Island layout with the mark on the left and current time on the right, so that the primary presentation matches the intended design.
21. As an iPhone user, I want the expanded Dynamic Island layout to preserve the left-mark/right-time composition, so that expanding the activity remains visually consistent.
22. As an iPhone user, I want the minimal Dynamic Island presentation to show a recognizable FloatClock mark, so that the activity remains identifiable when space is constrained.
23. As an iPhone user, I want the Lock Screen presentation to show the mark, `FloatClock`, and current time, so that its purpose remains understandable outside the Dynamic Island.
24. As an iPhone user, I want the time to use white monospaced system digits, so that it is stable and legible against the Dynamic Island.
25. As an iPhone user, I want FloatClock to reuse one pink-red brand accent in its mark and toggle, so that the app and Live Activity feel related.
26. As an iPhone user, I want the app to respect light and dark system appearance, so that the one-control screen remains native and readable.
27. As an iPhone user, I want tapping the Live Activity to open FloatClock, so that I can reach the toggle and turn it off.
28. As an iPhone user, I want the Live Activity to avoid extra controls, so that I don't accidentally end it from the Dynamic Island or Lock Screen.
29. As a VoiceOver user, I want the main toggle to expose a meaningful label, value, and state, so that I can control FloatClock without seeing the screen.
30. As a VoiceOver user, I want Live Activity content and failures to have localized accessible descriptions, so that the experience is understandable with assistive technology.
31. As a Simplified Chinese user, I want alerts, Settings guidance, and accessibility text in Simplified Chinese, so that I can understand the app.
32. As an English user, I want alerts, Settings guidance, and accessibility text in English, so that I can understand the app.
33. As an offline user, I want FloatClock to work without an account, server, or network connection, so that a local clock doesn't depend on remote infrastructure.
34. As an iPhone 15-or-later user, I want the app validated on my device class, so that its Dynamic Island behavior is supported by the release acceptance process.
35. As a product owner, I want the riskiest Live Activity scheduling assumption tested first, so that visual polish isn't built on an unproven platform behavior.
36. As a product owner, I want development to stop with evidence if the feasibility gate fails, so that the app doesn't silently ship approximate time or an undisclosed architecture change.

## Implementation Decisions

- The minimum deployment target is iOS 18 for the `TimeDataSource.currentDate` feasibility path. The app is iPhone-only. The required acceptance matrix begins with the iPhone 15 family and includes later iPhones; compatible older devices such as iPhone 14 Pro aren't deliberately blocked but aren't required QA targets.
- Use the native SwiftUI app lifecycle for the app target and SwiftUI with WidgetKit for the Widget Extension that provides the Live Activity.
- Use ActivityKit for Live Activity authorization, lookup, observation, creation, and ending.
- Use Swift Concurrency with `async`/`await`. Keep UI-observable state isolated to the main actor.
- Introduce one thin production test seam at the ActivityKit system boundary. It exposes only the operations needed to determine authorization, list or observe FloatClock activities, request one activity, and end activities. Don't introduce additional architecture or state-management frameworks.
- Do not proceed to full release implementation until a current-time-with-tenths update architecture passes physical-device acceptance. The previous local `TimelineView` architecture failed, and the elapsed-duration system timer text architecture is no longer accepted.
- FloatClock means an active Live Activity that presents the device-local current system time with one tenths digit. Do not display elapsed duration or countdown behavior.
- The main screen's only persistent content is one centered `Toggle` labeled `FloatClock`. It has no persistent title, explanation, secondary button, or status text.
- The toggle requests FloatClock state but isn't the source of truth. Reconcile its value with current ActivityKit activities when the app opens and when relevant activity state changes arrive.
- A transition to on requests at most one FloatClock. A transition to off ends and immediately dismisses all FloatClock activities owned by the app, which also cleans up any unexpected duplicates.
- Disable the toggle during in-flight start and stop operations. On failure, reconcile with ActivityKit again and present a localized transient alert rather than leaving an optimistic state visible.
- Configure the app to support Live Activities and check runtime authorization before requesting one. If Live Activities are unavailable or disabled, leave the actual state off and explain the failure in a localized alert.
- Don't persist an “always on” preference and don't automatically restart FloatClock after iOS or the user ends it. A requested activity targets the maximum duration iOS allows, currently up to eight active hours.
- The compact Dynamic Island presentation is primary: original FloatClock mark in the leading region and current time in the trailing region.
- The expanded presentation keeps the mark on the left and current time on the right. The minimal presentation shows only the mark. The Lock Screen presentation shows the mark, `FloatClock`, and current time.
- The app can't and doesn't attempt to pin the Dynamic Island in expanded form. All presentations tolerate system-selected width and truncation behavior.
- The Live Activity is display-only. Add no buttons, toggles, App Intents, or custom actions. Tapping it uses normal system behavior to open the app.
- Use white system typography with monospaced digits for the time. The entire time string is white; the reference's pink-red final tenths digit was dropped after HITL review confirmed the Dynamic Island rendering pipeline cannot split `Text(.currentDate, format:)` without breaking the display.
- Let iOS provide the Dynamic Island's black shape; don't draw another pill background. Use the system app background and automatically support light and dark appearance.
- Create an original alarm-clock mark inspired by the reference's pink-red rounded square and white clock concept. Don't use an SF Symbol or confusingly similar SF Symbol as the App Icon or brand mark. Use a full-color App Icon and a simplified small-size-safe form of the same mark in Live Activity presentations.
- Use the same pink-red brand accent for the mark and main toggle tint.
- Localize user-facing alerts, Settings guidance, accessibility descriptions, and supporting Lock Screen text in Simplified Chinese and English. Keep `FloatClock` unchanged. Current-time formatting must produce `mm:ss.S` using the selected update architecture.
- Keep version one fully local: no account, backend, analytics dependency, ActivityKit push notifications, or required network connection.
- Don't use silent audio, location, or any unrelated background mode to keep the app process alive.

## Testing Decisions

- Good tests assert externally observable behavior: actual toggle state, requested or ended Live Activities, displayed time, alerts, accessibility output, and rendered presentation. Tests must not assert private SwiftUI structure, task scheduling internals, or ActivityKit implementation details.
- The repository currently contains no application code or prior tests, so there is no existing test seam or prior test style to reuse. The single new production seam is the thin ActivityKit boundary agreed above.
- Test the main-screen state controller through the ActivityKit boundary with deterministic fakes. Cover initial reconciliation with zero, one, and duplicate activities; successful start; successful stop; disabled authorization; request failure; end failure; external termination; and rapid repeated input while an operation is in flight.
- Verify that activity creation captures one start anchor and that rendering reuses that anchor rather than recreating it. System-hosted timer animation has no faithful unit-test seam and remains a physical-device acceptance check.
- Use SwiftUI previews to inspect compact, expanded, minimal, and Lock Screen presentations with representative dates and both color appearances. Check spacing, legibility, monospaced width stability, system-selected constraints, and mark recognition.
- Use UI tests for the one-toggle main screen where the system boundary can be controlled. Verify the absence of extra persistent controls, the disabled in-flight state, localized failure alerts, and the toggle's VoiceOver label/value/state in Simplified Chinese and English.
- Visually verify the original mark at App Icon size and in compact and minimal Live Activity presentations. Confirm it remains recognizable and isn't a direct SF Symbol reproduction.
- The feasibility spike and final release require a physical-device smoke test: start FloatClock on an iPhone 15 or later, return to the Home Screen, and confirm the displayed `mm:ss.S` current time advances for at least 10 consecutive seconds without freezing.
- Simulator, SwiftUI preview, and debugger-attached results aid development but don't satisfy the feasibility or release gate.
- Low Power Mode behavior may be characterized, but it isn't part of the initial hard guarantee.
- If the feasibility gate fails, stop full development and record device model, iOS version, observed refresh cadence, time to failure, Home Screen behavior, Lock Screen behavior, hour-boundary behavior, and minimal reproduction code. Present duration semantics and a separately approved APNs-backed architecture as choices; implement neither without a new decision.

## Out of Scope

- Elapsed duration from the switch-on moment or countdown behavior.
- iPad, Apple Watch, Mac, CarPlay, Android, or web experiences.
- Required QA support for devices older than the iPhone 15 family, even when they can run the app.
- A model-generation allowlist or deliberate blocking of compatible older iPhones.
- Keeping the Dynamic Island permanently expanded.
- Controls or buttons inside the Dynamic Island or Lock Screen Live Activity.
- App Intents, shortcuts, Control Center controls, widgets other than the required Live Activity, and automation triggers.
- Automatic restart after the system or user ends a Live Activity.
- Accounts, synchronization, backend services, APNs updates, analytics dependencies, or required network access.
- Misusing background audio, location, or other background modes for process lifetime.
- UIKit, third-party UI libraries, or external state-management frameworks.
- Persistent explanatory content, onboarding, settings screens, secondary controls, or decorative main-screen content.
- Languages other than Simplified Chinese and English in version one.
- Long-running Home Screen, lock/wake, one-hour boundary, screen-off, and Low Power Mode guarantees.
- Continuing complete product development after a failed feasibility gate without a new product decision.

## Further Notes

- The supplied visual reference is `ref/design/floatclock.jpg`. It informs the left-mark/right-time composition, white time digits, pink-red final tenths digit, and brand accent; the final design uses an original brand mark.
- `CONTEXT.md` is authoritative for the terms FloatClock and FloatClock state. In particular, don't call FloatClock a stopwatch or timer.
- ADR-0018 supersedes ADR-0017, ADR-0015, and ADR-0001 and returns FloatClock to device-local current time with tenths precision. The prior wall-clock failure in `docs/testing/floatclock-feasibility-result.md` still blocks full release development until a new architecture is selected and proven.
- ActivityKit and iOS control presentation selection, scheduling cadence, authorization, and maximum lifetime. Release acceptance only guarantees the short physical-device smoke scenario in ADR-0016; longer-running behavior isn't a release gate.
