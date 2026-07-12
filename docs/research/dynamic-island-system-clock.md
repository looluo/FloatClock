# 在 iPhone 灵动岛显示实时系统时间：ActivityKit / SwiftUI 可行性研究

日期：2026-07-12

## 结论

**有一条 Apple 明示支持、且当前仓库尚未验证的新路线：iOS 18 的 `TimeDataSource.currentDate`。** Apple 明确说明，`TimeDataSource` 能向 `Text` 提供“实时且自动更新”的值，适用于 Widgets、Live Activities、watchOS Complications 和普通 app；它不依赖 app 在后台持续运行，也不需要每秒调用 `Activity.update` 或发送 APNs 推送。[TimeDataSource](https://developer.apple.com/documentation/swiftui/timedatasource)

首选候选是直接格式化真实当前日期，而不是把“从午夜经过的时长”伪装成壁钟：

```swift
Text(
    .currentDate,
    format: Date.FormatStyle()
        .hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)
        .second(.twoDigits)
        .secondFraction(.fractional(1))
)
.monospacedDigit()
```

`Date.FormatStyle` 从 iOS 18 起符合 `DiscreteFormatStyle`；`Text` 的 `TimeDataSource` initializer 也从 iOS 18 起接受任意相匹配的 `DiscreteFormatStyle`。`DiscreteFormatStyle` 的用途正是让连续变化的输入保持显示更新，并告知系统下一个离散边界。[DiscreteFormatStyle](https://developer.apple.com/documentation/foundation/discreteformatstyle) [Date.FormatStyle](https://developer.apple.com/documentation/foundation/date/formatstyle) [TimeDataSource.currentDate](https://developer.apple.com/documentation/swiftui/timedatasource/currentdate)

本机 iPhoneOS 26.5 SDK 类型定义确认上述 API 的最低系统版本为 iOS 18；本机 Foundation 小实验还确认：带 `.secondFraction(.fractional(1))` 的 `Date.FormatStyle` 输出 `mm:ss.S`，其下一个离散边界落在下一个十分之一秒。这纠正了仓库旧研究“Apple 没有官方支持的十分之一秒 Live Activity 路线”的结论。旧结论对 `TimelineView`、本地 `Activity.update` 循环和 APNs 10 Hz 更新仍然成立，但没有覆盖 iOS 18 新增的 `TimeDataSource` / `DiscreteFormatStyle` 机制。

不过，**“API 层面可表达”还不等于“FloatClock 已通过验收”**。必须在支持灵动岛的物理 iPhone 上验证：解锁后的 Home Screen / app 内灵动岛能否持续按 10 Hz 显示 `mm:ss.S`，以及锁屏、Always-On、低电量和热状态下降级时的行为。Apple 明示 `TimeDataSource` 支持 Live Activities，但没有承诺所有设备状态都按 10 Hz 刷新可见像素；Always-On 还会主动限制动画和秒级呈现。[Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities) [iOS 18 release notes](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-18-release-notes)

## 需求要分成两层

### 1. 用户泛指的“系统时间”

如果需求是标准壁钟，例如 `HH:mm:ss`，最正确的表达是：

```swift
Text(
    .currentDate,
    format: Date.FormatStyle()
        .hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)
        .second(.twoDigits)
)
```

这直接格式化 `Date.now`，能正确处理跨午夜、夏令时和系统时钟调整；格式器默认 locale 是 `autoupdatingCurrent`，因此也有跟随用户区域设置变化的基础。[TimeDataSource.currentDate](https://developer.apple.com/documentation/swiftui/timedatasource/currentdate) [Date.FormatStyle locale](https://developer.apple.com/documentation/foundation/date/formatstyle/locale)

12/24 小时制需要产品先定语义：

- 若应尊重用户系统偏好，应使用 locale-aware 的 `Date.FormatStyle`，保留合适的 AM/PM 表达。
- 若产品必须固定 `HH:mm:ss` 24 小时制，可以使用明确的 hour symbol，或 `Date.VerbatimFormatStyle` 固定 pattern；但 Apple 建议给人阅读的日期时间优先使用 locale-aware `dateTime`，verbatim 更适合必须精确固定格式的程序化字符串。[Date.FormatStyle](https://developer.apple.com/documentation/foundation/date/formatstyle) [verbatim(_:locale:timeZone:calendar:)](https://developer.apple.com/documentation/foundation/formatstyle/3996606-verbatim)

### 2. FloatClock 当前更严格的需求

仓库 ADR-0018 要求的是设备本地当前时间的 `mm:ss.S`，不是普通 `HH:mm:ss`，也不是 elapsed duration。当前实现位于 `FloatClockLiveActivity/FloatClockLiveActivity.swift`，使用 `TimelineView(.periodic(from: .now, by: 0.1))`；物理机结果记录为初值出现后在 Home Screen 冻结。APNs spike 也只看到大于 5 秒的间隔，约两次后冻结。

iOS 18 新 API 可以直接表达该严格需求：`TimeDataSource.currentDate` + `Date.FormatStyle().minute(.twoDigits).second(.twoDigits).secondFraction(.fractional(1))`。Apple 的 `SecondFraction.fractional(1)` 官方示例说明它输出一位秒的小数。[SecondFraction](https://developer.apple.com/documentation/foundation/date/formatstyle/symbol/secondfraction) [secondFraction(_:)](https://developer.apple.com/documentation/foundation/date/formatstyle/secondfraction%28_%3A%29)

因此首轮 spike 不应再使用 `TimelineView`，而应只替换 Live Activity 内部的时间文本为 `Text(.currentDate, format: ...)`，其余 ActivityKit 生命周期保持不变。

## 候选方案分级

### A. 首选：`currentDate` + `Date.FormatStyle`（iOS 18+）

优点：

- 输入是真实 `Date.now`，语义就是系统壁钟；不需要午夜 anchor。
- 跨午夜、时区、DST 和手动校时由日期格式化语义处理，而非靠 elapsed duration 猜测。
- `Date.FormatStyle` 可指定 hour/minute/second/secondFraction；一位 fraction 能表达 `mm:ss.S`。[Date.FormatStyle](https://developer.apple.com/documentation/foundation/date/formatstyle) [SecondFraction](https://developer.apple.com/documentation/foundation/date/formatstyle/symbol/secondfraction)
- `TimeDataSource` 官方明确把 Live Activities 列为自动更新支持场景。[TimeDataSource](https://developer.apple.com/documentation/swiftui/timedatasource)

风险：

- Apple 没有单独承诺 Dynamic Island 在所有功耗状态都可见地维持 10 Hz；必须物理机测。
- locale-aware formatter 可能根据 locale 调整字段顺序、分隔符或 12/24 小时表达。若 UI 必须逐字符一致，要明确本地化策略。
- `Date.FormatStyle` 的 `DiscreteFormatStyle` conformance 以及 `TimeDataSource` 都要求 iOS 18；当前工程 deployment target 是 iOS 17，所以要么提升最低版本，要么为 iOS 17 保留降级路径，而 iOS 17 无法满足十分之一秒验收。

### B. 次选：`currentDate` + `SystemFormatStyle.Stopwatch`，以本地午夜为起点（iOS 18+）

```swift
let midnight = Calendar.autoupdatingCurrent.startOfDay(for: .now)

Text(
    .currentDate,
    format: .stopwatch(
        startingAt: midnight,
        showsHours: true,
        maxFieldCount: 4,
        maxPrecision: .milliseconds(100)
    )
)
```

这是比旧 `Text(timerInterval:countsDown:)` 更明确的高精度系统格式：Apple 说明 `Stopwatch` 默认显示百分之一秒；`maxPrecision: .milliseconds(100)` 的官方示例输出一位小数；`SystemFormatStyle` 借助 `DiscreteFormatStyle` 让 SwiftUI 在正确的离散时刻高效调度更新。[SystemFormatStyle.Stopwatch](https://developer.apple.com/documentation/swiftui/systemformatstyle/stopwatch) [Stopwatch initializer](https://developer.apple.com/documentation/swiftui/systemformatstyle/stopwatch/init%28startingat%3Ashowshours%3Amaxfieldcount%3Amaxprecision%3A%29) [SystemFormatStyle](https://developer.apple.com/documentation/swiftui/systemformatstyle)

但它是**经过时长**，不是真正的民用壁钟：

- 到第二天不会回到 `00:00:00.0`；Apple 明示超过 25 小时会继续显示 `25:01:01.00`。
- DST 跳变日，“从午夜实际经过的秒数”不等于当地钟面时间。
- Live Activity 创建后若时区变化，已计算的 midnight 是绝对 `Date`，不会自动变成新时区当天午夜。
- 它自身不表达 12/24 小时制；它是 duration pattern。`showsHours` 只决定达到一小时后是否单列 hours，不能表达 AM/PM 偏好。Apple 文档也明确小时字段在 elapsed time 达到一小时才自动加入。[SystemFormatStyle.Stopwatch](https://developer.apple.com/documentation/swiftui/systemformatstyle/stopwatch)

Live Activity 最多活跃 8 小时会降低“跨多日”的概率，但并不能消除跨午夜和 DST 风险。[Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)

所以该方案适合作为验证系统能否在 Live Activity 中持续做 100 ms 更新的对照组，不应优先于直接 `Date.FormatStyle`。

### C. 旧 API：`Text(timerInterval:pauseTime:countsDown:showsHours:)`（iOS 16+）

Apple 的 Food Truck 官方示例确实在 Dynamic Island 的 compact trailing 区使用 `Text(timerInterval:countsDown:)`，所以它属于 Apple 明示支持的 Live Activity timer text，而不是 `TimelineView` 式推测。[Food Truck sample](https://developer.apple.com/documentation/swiftui/food-truck-building-a-swiftui-multiplatform-app)

但它只显示给定 interval 内的倒计时或正计时。`showsHours` 的官方定义是“当 timer 剩余超过 60 分钟时是否包含小时”；它没有自定义十分之一秒的参数，也不能保证固定显示两位小时或遵循用户 12/24 小时偏好。[Text timerInterval initializer](https://developer.apple.com/documentation/swiftui/text/init%28timerinterval%3Apausetime%3Acountsdown%3Ashowshours%3A%29)

把 interval 起点设为本地午夜、`countsDown: false`，最多只能近似得到 elapsed `H:mm:ss`。它仍有 `Stopwatch` 的跨午夜、DST、时区变化问题，并且不支持 `mm:ss.S`。因此它只适合秒级 duration，不是 FloatClock 的方案。

### D. 自定义 `DiscreteFormatStyle<Date, String>`（iOS 18+，实验性）

泛型 `Text(TimeDataSource, format:)` 接受任何 `DiscreteFormatStyle`，因此理论上可以自定义每 100 ms 的离散边界并格式化 `mm:ss.S`。[DiscreteFormatStyle](https://developer.apple.com/documentation/foundation/discreteformatstyle) [TimeDataSource](https://developer.apple.com/documentation/swiftui/timedatasource)

但现成的 `Date.FormatStyle` 已能表达相同结果，并且由 Foundation 负责 locale、calendar、time zone 和离散边界。只有在系统格式器无法满足视觉拆色等要求时才值得测试自定义 style；widget / Live Activity 的 view archive、低功耗降级和跨系统版本行为仍需物理机验证。

### E. 不推荐：app 10 Hz 更新或 APNs 10 Hz 更新

Live Activity extension 不能联网；动态数据应由 app 的 ActivityKit 更新或 ActivityKit push 提供。App 在获得后台 runtime 时可以更新，但 Apple 没有给普通 app 持续后台 10 Hz 执行权。[Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities) [Meet ActivityKit, WWDC23](https://developer.apple.com/videos/play/wwdc2023/10184/)

APNs 更新有预算：低优先级会 opportunistically 送达，高优先级受系统预算并可能 throttle；“frequent updates”示例是篮球赛每分钟多次更新，而且用户可以关闭。设备也可能根本收不到 push。因此它不适合运输设备本地时钟的每个 tick。[Starting and updating Live Activities with ActivityKit push notifications](https://developer.apple.com/documentation/activitykit/starting-and-updating-live-activities-with-activitykit-push-notifications) [Update Live Activities with push notifications, WWDC23](https://developer.apple.com/videos/play/wwdc2023/10185/)

## 生命周期、Always-On 与展示限制

- Live Activity 最多 active 8 小时；到时系统结束它并立即从 Dynamic Island 移除。它可在 Lock Screen 再保留最多 4 小时，总计最多 12 小时。一个“永久时钟”必须接受用户定期重新启动，不能承诺常驻。[Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- 用户可以关闭某个 app 的 Live Activities，也可以手动移除；启动前应检查 `areActivitiesEnabled`。[Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- Dynamic Island 是支持机型解锁后的系统位置；锁屏时产品要同时考虑 Lock Screen presentation，而不是把灵动岛当成锁屏常驻画布。[Apple Support: View Live Activities in the Dynamic Island](https://support.apple.com/guide/iphone/view-live-activities-in-the-dynamic-island-iph28f50d10d/ios)
- Always-On 会调暗屏幕，并把 Live Activity 按 Dark Mode 渲染；应用可读取 `isLuminanceReduced` 调整颜色。Apple 还说明 Always-On 下为省电不执行动画。[Creating custom views for Live Activities](https://developer.apple.com/documentation/activitykit/creating-custom-views-for-live-activities) [Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- iOS 18 release notes 记录了针对长时 Live Activity 自动更新时间文本耗电的修复，也记录了 `Text` 在 Always-On 下显示 seconds 属于需要修正的输出。这意味着不要把锁屏 Always-On 下持续显示秒或十分之一秒作为保证；应把验收重点放在解锁后的 Dynamic Island，并单列 AOD 降级行为。[iOS 18 release notes](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-18-release-notes)

## 产品与审核边界

Apple 的 HIG 要求 Live Activity 对应有明确开始和结束的任务或事件，最适合不超过 8 小时的短到中期活动；Apple 的 WWDC 也要求由明确用户动作请求 Live Activity。单纯复制系统时间虽然没有被 App Review Guidelines 明文禁止，但与“正在发生的任务/事件”语义较弱，存在产品定位与审核解释风险，建议让用户显式开启一个有边界的“专注时钟/计时显示会话”，并在 8 小时内自然结束。[Live Activities HIG](https://developer.apple.com/design/human-interface-guidelines/live-activities) [Meet ActivityKit, WWDC23](https://developer.apple.com/videos/play/wwdc2023/10184/)

还必须：

- 支持 Lock Screen、compact、minimal、expanded 全部 presentation，而不是只实现灵动岛某一种。[Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- 不在 Live Activity 中展示广告或推广；避免敏感信息，因为锁屏和 Always-On 可能被旁人看到。[Live Activities HIG](https://developer.apple.com/design/human-interface-guidelines/live-activities)
- 不用 Live Activities 发送垃圾信息或未经请求的消息。[App Review Guidelines 4.5.3](https://developer.apple.com/app-store/review/guidelines/)

## 最低系统与设备

- Live Activities / ActivityKit 从 iOS 16.1 可用，Dynamic Island 首发硬件为 iPhone 14 Pro / Pro Max；没有灵动岛的设备仍可显示 Lock Screen Live Activity。[Apple Developer News: iOS 16.1 ActivityKit](https://developer.apple.com/news/?id=ttuz9vwq)
- 旧 `Text(timerInterval:pauseTime:countsDown:showsHours:)` 从 iOS 16 可用。
- 本研究首选的 `TimeDataSource`、`Text(TimeDataSource, format:)`、`SystemFormatStyle`，以及 `Date.FormatStyle` 的 `DiscreteFormatStyle` conformance 从 iOS 18 可用。[TimeDataSource](https://developer.apple.com/documentation/swiftui/timedatasource) [SystemFormatStyle](https://developer.apple.com/documentation/swiftui/systemformatstyle)
- 当前 FloatClock 工程 deployment target 是 iOS 17，ADR-0002 也写明 iOS 17。采用首选路线需要把产品最低版本提升为 iOS 18，或承认 iOS 17 只能降级且不满足 `mm:ss.S` 验收。

## 建议的物理机 spike

只做最小范围改动来验证机制，不先改产品架构：

1. 将测试 target 临时设为 iOS 18+。
2. 在现有 `ActivityConfiguration` 中，用 `Text(.currentDate, format: Date.FormatStyle()...secondFraction(.fractional(1)))` 替换 `TimelineView`；不要增加 background mode、`Activity.update` timer 或 APNs。
3. 同时放两个测试文本：A 为直接 `Date.FormatStyle` 的 `mm:ss.S`，B 为午夜 anchor 的 `.stopwatch(...maxPrecision: .milliseconds(100))`，便于区分 date formatter 与系统 stopwatch 的宿主行为。
4. 在支持灵动岛的物理 iPhone 上观察至少 15 分钟：前台 app、解锁 Home Screen、其他 app 覆盖、锁屏、Always-On、低电量模式。
5. 用 240 fps 视频或屏幕外拍统计十秒内是否出现约 100 个有序十分之一秒状态；记录 freeze、降频、跳帧、错位和电量/热状态。
6. 专门测试 `59.9 -> 00.0` 的分钟回绕、跨小时、跨午夜、自动时区变化、手动改时间、DST 模拟，以及 Live Activity 8 小时终止。
7. 成功标准必须分开：解锁 Dynamic Island 的 `mm:ss.S` 10 Hz；Lock Screen 秒级；Always-On 允许系统降级。不要用 AOD 的限制否决解锁灵动岛，也不要把解锁成功外推成 AOD 保证。

## 对当前仓库的判断

当前 ActivityKit 骨架是正确的：widget extension 用 `ActivityConfiguration` 提供 Lock Screen 和 Dynamic Island 各 presentation；app 使用 `Activity.request` 启动、`end` 停止；空 `ContentState` 也适合完全由系统时间驱动的显示。

真正需要重新验证的是 `FloatClockCurrentTimeText`：现有 `TimelineView(.periodic(..., by: 0.1))` 是已失败的调度机制。新的 `TimeDataSource.currentDate` 是 iOS 18 专门为 Widgets / Live Activities 的自动更新时间值设计的 API，不需要推翻现有 ActivityKit 生命周期，也不需要 APNs。下一步应先做该单点 spike；在结果出来前，不应再宣称产品不可实现，也不应宣称已经可发布。

