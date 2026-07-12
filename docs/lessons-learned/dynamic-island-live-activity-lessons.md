# Dynamic Island 实时时间显示：经验总结

日期：2026-07-12

## 概述

本文总结 FloatClock 项目在 Dynamic Island 中显示实时当前系统时间（`hh:mm:ss.S`）过程中遇到的技术挑战、失败的方案、最终解决方案，以及在反复迭代中积累的经验教训。

---

## 一、技术发现

### 1. `TimelineView` 在 Live Activity 中不可靠

**现象**：`TimelineView(.periodic(from:by: 0.1))` 在真机 Dynamic Island 中渲染一次后冻结。

**原因**：ActivityKit 不使用 WidgetKit timeline 机制更新 Live Activity 内容。SwiftUI 文档明确说系统可能使用比请求更慢的 cadence。

**结论**：不要用 `TimelineView` 作为 Live Activity 的周期性更新源。该路径在秒级和十分之一秒级都失败了。

**证据**：`docs/testing/current-time-with-tenths-feasibility-result.md`

### 2. APNs Live Activity push 无法支持高频更新

**现象**：APNs `liveactivity` push 更新在真机 Home Screen 上间隔超过 5 秒，约 2 次后冻结。

**原因**：APNs Live Activity 更新有系统预算、可能被节流、低优先级为 opportunistic 送达。Apple 文档将 frequent updates 描述为"每分钟多次"而非"每秒多次"。

**结论**：APNs 不适合传输设备本地时钟的每个 tick。

**证据**：`docs/testing/apns-current-time-with-tenths-feasibility-result.md`

### 3. iOS 18 `Text(.currentDate, format:)` 是可行方案

**发现**：研究文档 `docs/research/dynamic-island-system-clock.md` 发现 Apple 在 iOS 18 新增了 `TimeDataSource.currentDate`，与 `Date.FormatStyle`（符合 `DiscreteFormatStyle`）配合，能让 `Text` 在 Widgets、Live Activities 中自动更新，不需要 app runtime。

**验证**：真机 2 分钟连续十分之一秒更新无冻结。

**关键**：之前的失败结论（TimelineView、APNs）仍然成立，但没有覆盖 iOS 18 的 `TimeDataSource` 机制。这说明**"某条路线失败"不等于"所有路线失败"——需要持续追踪平台新 API**。

### 4. `TimeDataSource` 报告的 intrinsic size 远大于可见文本

**现象**：`Text(.currentDate, format: Date.FormatStyle()...)` 在 Dynamic Island compact trailing 中导致灵动岛过度撑大，把系统状态栏元素（时钟、电池）挤出屏幕。同样字符数的静态文本不会产生此问题。

**诊断过程**：

1. 放入 `EmptyView()` → 系统元素恢复 → 确认是内容导致
2. 放入静态 `Text("00:00.0")`（7字符 9pt）→ 系统元素正常 → 排除字符宽度问题
3. 放入 `Text(.currentDate, format:)`（同样 7字符 9pt）→ 系统元素消失 → **确认是 TimeDataSource 报告了过大尺寸**

**结论**：`TimeDataSource` 向布局系统报告的 intrinsic size 远大于实际渲染的字形宽度。Dynamic Island 渲染管线使用这个报告尺寸来决定灵动岛宽度。

**解决方案**：用 `.frame(width:)` 强制约束报告尺寸。`frame(width: 66)` 在 12pt 下既能容纳 `hh:mm:ss.S`，又能保持系统时钟和电池可见。

### 5. Dynamic Island compact trailing 尾部空间

**现象**：compact trailing 中的文本右侧存在额外空间。

**尝试过的无效方案**：
- `.frame(maxWidth: .infinity, alignment: .trailing)` — 无效
- `.padding(.trailing, -8)` — 无效
- `.contentMargins(.trailing, 0, for: .compactTrailing)` — 无效
- `.fixedSize(horizontal: true, vertical: false)` — 文本消失
- `.tracking(1.5)` — 无效果
- `ViewThatFits` — 无效果

**根因**：Dynamic Island compact trailing 有系统预留的槽位宽度。当内容（含 TimeDataSource 过大 intrinsic）超过标准宽度时，灵动岛撑大；当内容小于槽位时，存在尾部空间。`.frame(width:)` 同时解决了两个问题：约束 intrinsic + 控制槽位宽度。

### 6. Dynamic Island 渲染管线忽略部分 SwiftUI 修饰器

**已验证被忽略**：
- `.background()` — 不渲染
- `.padding()` — 不影响布局

**已验证生效**：
- `.foregroundStyle()` — 生效
- `.monospacedDigit()` — 生效
- `.font()` — 生效
- `.frame(width:)` — 生效，能约束报告尺寸

**结论**：Dynamic Island 的 WidgetKit 渲染管线不是完整的 SwiftUI 布局引擎。不能假设标准 SwiftUI 布局修饰器在 compact presentation 中生效。**用诊断背景（半透明色块）验证布局边界是有效手段**，但注意背景本身也可能被忽略。

### 7. 拆分 `Text(.currentDate, format:)` 会破坏显示

**现象**：将 `mm:ss` 和 `.S` 拆成两个独立的 `Text(.currentDate, format:)` 并放入 HStack 或 ZStack 后，出现 level down、小数位消失、重复显示等问题。

**结论**：`Text(.currentDate, format:)` 必须保持为单个完整文本。Dynamic Island 渲染管线对多个 TimeDataSource 文本的布局处理不稳定。这直接导致了红色小数位需求的放弃。

---

## 二、设计决策回顾

### 决策 1：从 elapsed duration 回到 current time

**背景**：ADR-0015 因 TimelineView 失败而将产品改为 elapsed duration。HITL 验收时用户明确拒绝：FloatClock 必须显示当前系统时间，不是从 0 开始的计时器。

**教训**：技术约束不应静默改变产品语义。当 feasibility gate 失败时，应停止并让产品决策者选择方向，而不是自动降级到一个未被接受的产品定义。

### 决策 2：从 mm:ss.S 改为 hh:mm:ss.S

**背景**：用户要求在紧凑显示中加入小时。系统状态栏时钟已在外部显示 `hh:mm`。

**教训**：compact Dynamic Island 空间极其有限。每增加一个字符，字号就必须缩小或 frame 必须加宽（可能挤掉系统元素）。格式选择直接影响可读性和系统元素共存。

### 决策 3：放弃红色小数位

**背景**：参考图中最后一位小数是粉红色。尝试拆分 TimeDataSource 文本着色失败（见技术发现 7）。

**教训**：视觉需求（拆色）与平台 API 约束（单一 TimeDataSource 文本）冲突时，功能正确性优先于视觉精度。记录决策原因，不要在不了解渲染管线限制的情况下反复尝试。

### 决策 4：compact 布局从"时间在右"改为"时间在左+电池在右"再改回

**背景**：用户一度要求时间在 compactLeading、电池在 compactTrailing。后来澄清系统时钟和电池在灵动岛外部，内部仍为左图标+右时间。

**教训**：在开始实现前，**必须明确每个元素的精确位置（灵动岛内部 vs 外部）**。模糊的需求描述会导致大量返工。

---

## 三、过程经验

### 1. 诊断驱动开发

面对"尾部空间"问题，经历了超过 15 次试错迭代。转折点是用**系统化诊断**替代盲试：

- `EmptyView` → 系统元素恢复 → 内容导致
- 静态文本 → 正常 → TimeDataSource 是问题根源
- 逐字符递增 → 找到宽度阈值

**建议**：遇到布局问题时，先用最小变量对照实验定位根因，再尝试修复。不要在没有诊断的情况下连续修改。

### 2. 真机不可替代

Simulator 无法复现：
- TimelineView 冻结
- APNs 节流
- compact trailing 尾部空间
- 系统状态栏元素消失
- `.fixedSize` 导致文本消失

**所有这些只在真机上出现**。Simulator 和 SwiftUI Preview 能验证编译和基本逻辑，但 Dynamic Island 的渲染行为必须真机验证。

### 3. 研究 skill 的价值

两次关键转折都来自研究文档：
- `docs/research/dynamic-island-system-clock.md` → 发现 iOS 18 TimeDataSource
- `docs/research/dynamic-island-compact-trailing-space.md` → 理解 contentMargins API（虽然最终方案不同）

**建议**：在反复试错超过 3 次后，暂停编码，投入时间做官方文档研究。这比继续盲试更高效。

### 4. 记录失败证据

项目保留了完整的失败记录：
- TimelineView 冻结证据
- APNs 节流证据
- 每次真机观察结果的 ticket 更新

这些记录让后续开发者（或 AI agent）不会重复已失败的路径。

---

## 四、最终架构

```
系统时钟 hh:mm    [📌图标    hh:mm:ss.S]    🔋电池
```

- **时间驱动**：iOS 18 `Text(.currentDate, format: Date.FormatStyle().hour(.twoDigits(amPM: .omitted)).minute(.twoDigits).second(.twoDigits).secondFraction(.fractional(1)))`
- **compact trailing 约束**：`.font(.system(size: 12, weight: .medium)).frame(width: 66)`
- **compact leading**：FloatClockMark（原创矢量 mark，20×20）
- **expanded**：mark + 完整时间（默认字号）
- **Lock Screen**：mark + FloatClock + 完整时间
- **minimal**：mark only
- **无 APNs、无后台模式、无 TimelineView**

---

## 五、给后续开发者的建议

1. **不要拆分 `Text(.currentDate, format:)`**。渲染管线不支持多个 TimeDataSource 文本共存。
2. **compact trailing 必须用 `.frame(width:)` 约束**。不约束会撑大灵动岛。
3. **frame 宽度直接影响系统元素可见性**。66pt 保留时钟+电池但挤掉 WiFi/蜂窝。如果需求变化，需要重新验证。
4. **真机是唯一可靠的验证环境**。Simulator 和 Preview 会给出错误结论。
5. **追踪 iOS 新 API**。本项目两次被"以为不可能"阻挡，最终都被新 API 解决（`DiscreteFormatStyle` / `TimeDataSource`）。
