# 消除灵动岛 compact trailing 时间后的尾部空间

日期：2026-07-12

## 结论

FloatClock 当前的 `compactTrailing` 时间没有固定宽度、显式 `padding` 或 `Spacer`；`Date.FormatStyle` 的诊断输出也没有尾随空白。因此，现阶段最值得优先验证的解释是：**系统为 Dynamic Island 的 `.compactTrailing` presentation 提供了默认 content margin**，而不是格式化字符串末尾多了空格。

WidgetKit 提供了精确针对这一层的 API：

```swift
DynamicIsland {
    // expanded regions
} compactLeading: {
    // mark
} compactTrailing: {
    FloatClockCompactTrailingRegion()
} minimal: {
    // mark
}
.keylineTint(.white)
.contentMargins(.trailing, 2, for: .compactTrailing)
```

Apple 将 `contentMargins(_:_:for:)` 定义为覆盖指定 Dynamic Island presentation 的默认 content margins；`DynamicIslandMode.compactTrailing` 则只选择 compact trailing presentation。[DynamicIsland](https://developer.apple.com/documentation/widgetkit/dynamicisland) [DynamicIslandMode](https://developer.apple.com/documentation/widgetkit/dynamicislandmode)

**建议把 `2 pt` 作为候选默认值，但在真机 A/B 完成前不把它当作已验证修复。** 最小实验应比较系统默认值与 `4 / 2 / 0 pt`。如果右侧间距随数值单调变化，才足以把主要原因归到默认 content margin；如果变化很小或完全不变，应继续检查 `Text` 的布局宽度与字体的光学边界。

## 当前仓库证据

当前实现位于 [`FloatClockLiveActivity/FloatClockLiveActivity.swift`](../../FloatClockLiveActivity/FloatClockLiveActivity.swift)：

- `compactTrailing` 直接返回 `FloatClockCompactTrailingRegion`，其后只有 `.keylineTint(.white)`；Dynamic Island 本身尚未调用 `contentMargins`。
- `FloatClockCompactTrailingRegion` 是一个 `Text(.currentDate, format: ...)`，只应用 `.font(.title3.monospacedDigit())` 和白色前景。
- 该 compact view 没有 `.frame(width:)`、`.frame(maxWidth:)`、`.padding(...)`、`Spacer` 或容器布局，所以当前源码中不存在显式制造尾部空间的固定布局。
- `.frame(maxWidth: .infinity, alignment: .trailing)` 只出现在 expanded trailing region，不作用于 compact trailing。

仓库已有真机测试记录 [`docs/testing/ios18-timedatasource-current-time-result.md`](../testing/ios18-timedatasource-current-time-result.md) 说明：早期实现曾有一个 `88 pt` 的 compact trailing 固定 frame，视觉复查时因其在时间后留下额外空间而移除。当前源码已不包含该 frame，因此“旧的 88 pt frame 仍在生效”可以排除。

既有 Foundation 诊断还确认 `.minute(.twoDigits).second(.twoDigits).secondFraction(.fractional(1))` 产生 `mm:ss.S`，末尾没有空格或不可见字符；相关时间格式研究记录在 [`docs/research/dynamic-island-system-clock.md`](dynamic-island-system-clock.md)。这能排除**字符串内容空白**，但不能单独排除 SwiftUI 布局、系统 margin 或字形 side bearing。

## 四类“空白”必须分开判断

### 1. 文本内容空白

这是格式化结果中真实存在的空格、不可见字符或额外字段。它会跟着字符串进入任何宿主布局。

FloatClock 的诊断输出不含尾随字符，因此该假设目前证据最弱。若后续更改 locale、format style 或拆分多个 `Text`，仍应重新记录格式化结果的 Unicode scalars，避免把新的格式变化误判为系统 margin。

### 2. `Text` 的 intrinsic / reserved width

即使字符串没有空格，SwiftUI `Text` 的布局矩形也不等于屏幕上可见字形墨迹的最小包围盒。当前 `.monospacedDigit()` 让数字具有稳定宽度，但 Apple 没有在所引用的 `TimeDataSource` / `Text` 文档中承诺该动态文本的布局宽度一定紧贴最后一个可见像素。因此，这一层应当保留为待验证假设，不能仅凭字符串输出排除。

若 `contentMargins` A/B 几乎不改变可见间距，可在单独的诊断构建里给 `Text` 加半透明背景来显示其布局矩形：

- 背景矩形贴近岛的外缘、但数字墨迹仍显得偏左：更像字体光学边界。
- 背景矩形本身已经比内容需要的宽：更像 `Text` / 容器的 reserved width。
- 背景矩形与岛外缘之间仍有明显区域，且该区域随 `contentMargins` 改变：更像系统 content margin。

这只是诊断手段，不应进入产品样式。

### 3. Dynamic Island 默认 content margins

这是当前首要假设。Apple 的 API 明确表示 `contentMargins` 会覆盖指定 presentation mode 的**默认** margin；`.compactTrailing` 是一个独立的 `DynamicIslandMode`，所以无需影响 compact leading、minimal 或 expanded。[`contentMargins`](https://developer.apple.com/documentation/widgetkit/dynamicisland/contentmargins(_:_:for:)) [`compactTrailing`](https://developer.apple.com/documentation/widgetkit/dynamicislandmode/compacttrailing)

Apple 没有在该 API 页面公开承诺默认 margin 的具体点数。因此，不应反推或硬编码一个所谓“系统默认值”；应直接以未加 modifier 的构建作为 baseline。

### 4. 字体光学边界

字体布局使用 advance width 和 side bearings；可见 glyph outline 不会必然填满其布局宽度。Apple 的 TrueType 文档明确指出 advance width 会包含用于正常字间距的额外空白（side bearings），并说明字形在边缘可能产生视觉上不齐的现象。[Apple TrueType Reference Manual: Optical Bounds](https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6AATIntro.html) [Horizontal Metrics Table](https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6hmtx.html)

因此，即使将系统 trailing margin 覆盖为 `0`，最后一个数字的可见笔画和岛的边缘之间仍可能留有少量、合理的光学空白。使用负 padding 去抵消字形 side bearing 风险较高，也不是本研究的首选方案。

## trailing 与 leading 到底指哪一侧

这里有两个不同概念，容易混淆：

1. **`.compactTrailing` mode**：选择位于 TrueDepth camera trailing side 的那一个 compact presentation。Apple 说明，单个 Live Activity 的 compact presentation 由 camera leading side 和 trailing side 的两个独立 view 共同组成。[Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
2. **`.contentMargins(.trailing, ..., for: .compactTrailing)` 的 `.trailing` edge**：选择这个 presentation 自身的 trailing 外缘。在常见的从左到右布局中，它是时间右侧、远离 camera 的外缘；`.leading` 是时间左侧、靠近 camera 的内缘。

`leading` / `trailing` 是语义方向而不是永远固定的物理左/右；SwiftUI 会依据 layout direction 镜像水平布局。[LayoutDirection](https://developer.apple.com/documentation/swiftui/layoutdirection) 因此产品代码应使用 `.trailing`，不要改写成硬编码“右侧”的布局逻辑。若用户指出的是时间与 camera 之间的空隙，应测试 `.leading`，而不是 `.trailing`。

## 最小真机 A/B 实验

### 实验矩阵

保持代码、字体、时间格式、设备方向和 Live Activity 状态完全一致，只改变一处 modifier：

| 变体 | 配置 | 用途 |
| --- | --- | --- |
| A | 不调用 `contentMargins` | 系统默认 baseline |
| B | `.contentMargins(.trailing, 4, for: .compactTrailing)` | 保守收紧候选 |
| C | `.contentMargins(.trailing, 2, for: .compactTrailing)` | 推荐候选默认值 |
| D | `.contentMargins(.trailing, 0, for: .compactTrailing)` | 判断可消除空间的上限 |

每个变体都在同一台支持 Dynamic Island 的物理 iPhone 上启动新的 Live Activity，回到 Home Screen，截取 compact presentation。尽量让时间末位相同，或至少各记录多个末位数字，以避免不同 glyph 的光学形状影响判断。截图应保持同一缩放比例，并测量“最后一个可见 glyph 像素到 Dynamic Island 外缘”的距离。

如有两种宽度的设备，至少补测一台 230 pt compact/minimal 宽度设备与一台 250 pt 设备；Apple 的 HIG specifications 显示当前支持机型存在这两类宽度。[Live Activities HIG: Specifications](https://developer.apple.com/design/human-interface-guidelines/live-activities#Specifications)

### 成功标准

候选值只有同时满足以下条件才算通过：

- 时间后的可见空隙相对 baseline 明显减小，且 `4 → 2 → 0` 呈可解释的变化。
- `00:00.0`、`11:11.1`、`59:59.9` 等不同轮廓的数字均不被裁切。
- compact leading 图标、camera 两侧平衡以及岛的整体外形没有被破坏。
- Live Activity 从 compact 展开再收回后，margin 仍稳定；时间持续更新时没有横向跳动或裁切。
- 左到右与可用的从右到左 layout direction 下，语义 trailing edge 行为正确。
- 至少覆盖目标支持范围内的最窄和最宽 Dynamic Island compact 宽度，或将未覆盖机型明确列为发布风险。

若 `4 / 2 / 0` 与 baseline 没有可辨识差异，则实验没有支持“默认 content margin 是主因”，下一步应使用临时背景标出 `Text` 布局矩形，继续区分 reserved width 与字体光学边界。

## 风险与设计边界

- **裁切风险**：`0 pt` 可能让字形、抗锯齿像素或动态更新时的内容过于靠近圆角；不同末位数字必须分别观察。
- **HIG 风险**：Apple 要求内容紧凑，但仍要在 Dynamic Island 外缘内保持协调、同心的 margin，避免内容戳入圆角或造成视觉张力；HIG 并不支持“越贴边越好”。[Live Activities HIG](https://developer.apple.com/design/human-interface-guidelines/live-activities)
- **机型风险**：Dynamic Island 的 compact 宽度随机型变化，单机截图不足以证明所有尺寸安全。
- **locale / layout direction 风险**：leading 与 trailing 会随布局方向变化。FloatClock 当前时间格式虽主要由数字组成，宿主方向仍可能镜像边缘含义。
- **字体风险**：换字体、字号、字重或取消 `monospacedDigit()` 都会改变 advance width 和 side bearings，margin 结论需要重新验证。
- **负 inset 风险**：不建议用负 padding 或其他把内容推出系统安全区域的办法。它可能在当前截图上更紧，却增加不同机型、字号和系统版本下的裁切概率。

WWDC23 的 Dynamic Island 设计讲解强调，岛内内容的位置必须与外形保持和谐，文本与对象应保留同心 margin、避免靠侧壁太近；同时又应紧凑利用空间。[WWDC23: Design dynamic Live Activities](https://developer.apple.com/videos/play/wwdc2023/10194/) 这支持从 `4 / 2 / 0` 中选择“最小但仍舒适”的值，而不是预先指定 `0`。

## 建议

1. 先做上述四档真机 A/B，不同时更改字体、字号或时间拆分方式。
2. 将 `2 pt` 作为首选候选，因为它比默认 margin 更紧，又保留最小的显式安全距离；这是待验证建议，不是已观测结果。
3. 若 `2 pt` 通过全部成功标准，再在产品代码中只为 `.compactTrailing` 覆盖 `.trailing` margin。
4. 若 `2 pt` 裁切或显得紧张，退回 `4 pt`；若 `0 pt` 仅带来很小改善，不为追求像素级贴边承担 HIG 与机型风险。
5. 若所有档位差异不明显，停止继续压 margin，转而用诊断背景定位 `Text` reserved width 与字体光学边界。

本研究没有修改产品代码，也没有声称任何候选值已经通过物理机验证。

## Apple 一手资料

- [DynamicIsland](https://developer.apple.com/documentation/widgetkit/dynamicisland)
- [DynamicIslandMode](https://developer.apple.com/documentation/widgetkit/dynamicislandmode)
- [Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- [Human Interface Guidelines: Live Activities](https://developer.apple.com/design/human-interface-guidelines/live-activities)
- [WWDC23: Design dynamic Live Activities](https://developer.apple.com/videos/play/wwdc2023/10194/)
- [SwiftUI LayoutDirection](https://developer.apple.com/documentation/swiftui/layoutdirection)
- [Apple TrueType Reference Manual: Optical Bounds](https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6AATIntro.html)
- [Apple TrueType Reference Manual: Horizontal Metrics Table](https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6hmtx.html)
