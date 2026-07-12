import ActivityKit
import SwiftUI
import WidgetKit

struct FloatClockLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FloatClockAttributes.self) { context in
            FloatClockLockScreenContent()
                .padding()
                .activityBackgroundTint(.black)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    FloatClockExpandedContent()
                }
            } compactLeading: {
                FloatClockMark()
                    .frame(width: 20, height: 20)
            } compactTrailing: {
                FloatClockCompactTimeText()
            } minimal: {
                FloatClockMark()
                    .frame(width: 18, height: 18)
            }
            .keylineTint(.white)
        }
    }
}

private struct FloatClockExpandedContent: View {
    var body: some View {
        HStack(spacing: 0) {
            FloatClockMark()
                .frame(width: 40, height: 40)

            Spacer(minLength: 16)

            FloatClockCurrentTimeText()
        }
        .frame(maxWidth: .infinity)
    }
}

struct FloatClockCurrentTimeText: View {
    var body: some View {
        Text(
            .currentDate,
            format: Date.FormatStyle()
                .hour(.twoDigits(amPM: .omitted))
                .minute(.twoDigits)
                .second(.twoDigits)
                .secondFraction(.fractional(1))
        )
        .foregroundStyle(.white)
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
}

private struct FloatClockCompactTimeText: View {
    var body: some View {
        Text(
            .currentDate,
            format: Date.FormatStyle()
                .hour(.twoDigits(amPM: .omitted))
                .minute(.twoDigits)
                .second(.twoDigits)
                .secondFraction(.fractional(1))
        )
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(.white)
        .monospacedDigit()
        .lineLimit(1)
        .frame(width: 66)
    }
}

struct FloatClockLockScreenContent: View {
    var body: some View {
        HStack(spacing: 12) {
            FloatClockMark()
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text("FloatClock")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                FloatClockCurrentTimeText()
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Live Activity", as: .content, using: FloatClockAttributes()) {
    FloatClockLiveActivity()
} contentStates: {
    FloatClockAttributes.ContentState()
}

#Preview("Lock Screen") {
    FloatClockLockScreenContent()
        .padding()
        .frame(maxWidth: 360)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .preferredColorScheme(.dark)
}

#Preview("Expanded") {
    FloatClockExpandedContent()
        .padding()
        .frame(maxWidth: 360)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .preferredColorScheme(.dark)
}

#Preview("Minimal") {
    FloatClockMark()
        .frame(width: 18, height: 18)
        .padding(4)
        .background(Color.black)
        .clipShape(Circle())
}
