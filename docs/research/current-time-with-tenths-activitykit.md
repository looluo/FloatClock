# Current Time With Tenths in ActivityKit Live Activities

Date: 2026-07-11

## Question

Can an iOS ActivityKit Live Activity display the device-local current wall-clock time with tenths precision (`mm:ss.S`) while the app is backgrounded or the user is on the Home Screen, and what architectures are officially supported?

## Short Answer

No officially documented ActivityKit architecture appears to support a reliable 10 Hz wall-clock display in a Live Activity while the app is backgrounded or the user is on the Home Screen.

Apple documents three relevant mechanisms:

1. Render the Live Activity UI in a WidgetKit extension with SwiftUI.
2. Update dynamic Live Activity content from the app with ActivityKit while the app has runtime.
3. Update dynamic Live Activity content remotely with APNs `liveactivity` pushes, subject to delivery priority, budgets, throttling, and optional frequent-update support.

None of those mechanisms is documented as a reliable periodic subsecond rendering loop for `mm:ss.S` current time.

## Findings

### Live Activity UI Is System-Rendered WidgetKit UI

Apple says Live Activities use WidgetKit for their user interface, while ActivityKit handles lifecycle, scheduling, updating, ending, and ActivityKit push notifications. Apple also states that, unlike the widget timeline mechanism, Live Activities are started and updated from the app with ActivityKit or with ActivityKit push notifications. Source: [Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities).

Apple's WidgetKit WWDC session describes the rendering model for widgets: widget extension code runs to produce and archive view representations, and when a widget is visible, the system process renders the archived representation rather than running the app's view code continuously. Source: [WWDC23, Bring widgets to life](https://developer.apple.com/videos/play/wwdc2023/10028/).

Apple says each Live Activity runs in its own sandbox and cannot access the network or receive location updates. To update dynamic data, use ActivityKit in the app or allow ActivityKit push notifications. Source: [Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities).

### `TimelineView` Is Not a Reliable Subsecond Live Activity Clock

`TimelineView` is a SwiftUI view that redraws content at scheduled points in time and supports periodic schedules with custom intervals. However, Apple explicitly says the system might use a cadence slower than the schedule's update rate. Source: [SwiftUI `TimelineView`](https://developer.apple.com/documentation/swiftui/timelineview).

Apple's ActivityKit documentation draws a distinction between widget timeline updates and Live Activity updates: Live Activities leverage WidgetKit, but "in contrast to the timeline mechanism you use to update your widgets' user interface," Live Activities are started and updated from the app with ActivityKit or ActivityKit push notifications. Source: [Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities).

Therefore, `TimelineView(.periodic(from:by: 0.1))` inside a Live Activity should not be treated as an officially supported 10 Hz rendering contract. The official `TimelineView` contract allows the system to slow the cadence, and the official Live Activity update model is ActivityKit content updates or ActivityKit push notifications, not widget-style periodic timeline refreshes.

Answer to (1): No. `TimelineView` can express a periodic schedule, but Apple documents that actual cadence may be slower, and ActivityKit docs do not document `TimelineView` as a reliable Live Activity subsecond update mechanism.

### Local App Updates Are Only Supported While the App Has Runtime

Apple says apps generally start Live Activities while foregrounded. Apple also says an app can update or end a Live Activity while it runs in the background, for example by using `BGProcessingTask`. Source: [Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities).

That is not the same as a continuous 0.1-second update loop after the app is backgrounded. The documented local path is ActivityKit `Activity.update(...)` while the app has execution time. Apple does not document any ActivityKit entitlement or background mode that allows arbitrary local app code to keep updating Live Activity content at 10 Hz while suspended or on the Home Screen.

Apple's push-update WWDC session frames APNs Live Activity pushes as the way to keep Live Activities up to date without requiring foreground runtime: server-side updates mean "the app should not need foreground runtime to update the Live Activity." Source: [WWDC23, Update Live Activities with push notifications](https://developer.apple.com/videos/play/wwdc2023/10185/).

Answer to (2): No. Local ActivityKit updates are officially supported only when the app has runtime. Apple documents background updates as possible during background execution, but does not document continuous 10 Hz local Live Activity updates while the app is backgrounded or suspended.

### APNs Live Activity Pushes Do Not Support 10 Hz as a Contract

Apple documents `liveactivity` APNs pushes for starting, updating, and ending Live Activities. The request uses `apns-push-type: liveactivity`, an ActivityKit push token or channel, and payload fields such as `timestamp`, `event`, and `content-state`. Source: [Starting and updating Live Activities with ActivityKit push notifications](https://developer.apple.com/documentation/activitykit/starting-and-updating-live-activities-with-activitykit-push-notifications).

Apple says the system allows a certain budget of ActivityKit push notifications per hour. High-priority pushes count toward this budget, and if the app exceeds the budget, the system may throttle ActivityKit push notifications. Low-priority pushes do not count toward the budget, but are lower priority and should be considered first. Source: [Starting and updating Live Activities with ActivityKit push notifications](https://developer.apple.com/documentation/activitykit/starting-and-updating-live-activities-with-activitykit-push-notifications).

Apple describes frequent ActivityKit push notifications for use cases such as a basketball match that requires "many updates per minute." The feature increases update budget, can be disabled by users, and apps should detect `frequentPushesEnabled` and adjust server update frequency accordingly. Source: [Starting and updating Live Activities with ActivityKit push notifications](https://developer.apple.com/documentation/activitykit/starting-and-updating-live-activities-with-activitykit-push-notifications).

In WWDC23, Apple says low-priority updates are delivered opportunistically and may not update immediately, while high-priority updates are delivered immediately but have a system-imposed budget depending on device condition; exceeding the budget causes throttling. Source: [WWDC23, Update Live Activities with push notifications](https://developer.apple.com/videos/play/wwdc2023/10185/).

Answer to (3): No. APNs Live Activity pushes are not documented to support 10 Hz or near-10 Hz updates. The official model has per-hour budgets, opportunistic delivery for low priority, throttling for high priority, user-controlled frequent-update permission, and examples framed as many updates per minute rather than many updates per second.

## Officially Supported Architectures

### Architecture A: Local ActivityKit Updates

Start the Live Activity from the app with `Activity.request(...)`, render UI in the widget extension with `ActivityConfiguration`, and update dynamic state with `Activity.update(...)` while the app has foreground or granted background runtime. Source: [Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities) and [WWDC23, Meet ActivityKit](https://developer.apple.com/videos/play/wwdc2023/10184/).

This is suitable for discrete state changes. It is not an officially documented always-on 10 Hz background loop.

### Architecture B: APNs Push Token Updates

Start a Live Activity with `pushType: .token`, observe `pushTokenUpdates`, send the token to a server, and have the server send APNs `liveactivity` update or end events. Source: [Starting and updating Live Activities with ActivityKit push notifications](https://developer.apple.com/documentation/activitykit/starting-and-updating-live-activities-with-activitykit-push-notifications) and [WWDC23, Update Live Activities with push notifications](https://developer.apple.com/videos/play/wwdc2023/10185/).

This is suitable for remote event/state updates. It is not suitable for device-local wall-clock current time at 10 Hz because delivery is network-dependent, budgeted, and not tied to the device's exact local clock.

### Architecture C: APNs Channel or Broadcast Updates

For iOS 18 and later, Apple documents channel-based Live Activity updates and broadcast push notifications for updating or ending Live Activities for a large audience. Source: [Starting and updating Live Activities with ActivityKit push notifications](https://developer.apple.com/documentation/activitykit/starting-and-updating-live-activities-with-activitykit-push-notifications).

This is useful for shared live events, not a 10 Hz per-device local current-time display.

### Architecture D: System-Driven Text for Timers or Dates

Apple documents built-in animation and transitions for Live Activity content updates, including timer text, and SwiftUI has date/timer-oriented text APIs. Source: [Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities) and [SwiftUI `Text`](https://developer.apple.com/documentation/swiftui/text).

This may be worth testing only if the product can be expressed with Apple-supported system-rendered date/timer text. It is not documented as a tenths-precision `mm:ss.S` current wall-clock display.

## Minimum Viable Physical-Device Spike

The only spike worth testing for `mm:ss.S` is a negative/feasibility spike, not a product architecture commitment:

1. Build a Live Activity UI that uses the smallest possible `TimelineView(.periodic(from:by: 0.1))` or equivalent SwiftUI date-rendering experiment to render device-local `mm:ss.S`.
2. Put the app in the background and observe the Lock Screen and Dynamic Island on a physical iPhone for at least several minutes.
3. Record whether the value updates at 10 Hz, degrades to 1 Hz, freezes, or updates only on ActivityKit content changes.
4. Treat success as provisional only, because Apple documents that `TimelineView` cadence may be slower than requested and does not document it as a Live Activity subsecond guarantee.

If the goal is a shippable architecture supported by Apple documentation, the better spike is to test whether the acceptable product display can be reformulated to use system-supported timer/date text at coarser precision, or to abandon tenths precision for Live Activities.

## Direct Answers

1. Can `TimelineView` be relied on inside Live Activities for periodic subsecond updates?

No. Apple documents that `TimelineView` cadence may be slower than the requested schedule, and ActivityKit docs define Live Activity updates through ActivityKit app updates or ActivityKit push notifications rather than widget timeline refreshes.

2. Can local app code update Live Activity content every 0.1 seconds while backgrounded?

No documented support. Local updates can happen while the app has runtime, including some background runtime, but Apple does not document continuous 10 Hz local background Live Activity updates.

3. Can APNs Live Activity push updates support 10 Hz or near-10 Hz updates?

No documented support. APNs Live Activity updates are budgeted, may be throttled, low-priority delivery is opportunistic, and frequent updates are described for many updates per minute, not per second.

4. What minimum viable spike architecture is worth testing on a physical iPhone?

Test a minimal `TimelineView`/system date-rendering Live Activity on a physical iPhone as a feasibility spike only. Do not treat it as an officially supported architecture unless Apple documentation or physical-device testing proves the exact target behavior under background/Home Screen conditions.

## Source Index

- Apple, [Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- Apple, [Starting and updating Live Activities with ActivityKit push notifications](https://developer.apple.com/documentation/activitykit/starting-and-updating-live-activities-with-activitykit-push-notifications)
- Apple, [SwiftUI `TimelineView`](https://developer.apple.com/documentation/swiftui/timelineview)
- Apple, [SwiftUI `Text`](https://developer.apple.com/documentation/swiftui/text)
- Apple, [WWDC23: Meet ActivityKit](https://developer.apple.com/videos/play/wwdc2023/10184/)
- Apple, [WWDC23: Update Live Activities with push notifications](https://developer.apple.com/videos/play/wwdc2023/10185/)
- Apple, [WWDC23: Bring widgets to life](https://developer.apple.com/videos/play/wwdc2023/10028/)
