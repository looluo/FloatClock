import Foundation

struct FloatClockCurrentTimeParts: Equatable, Sendable {
    let minuteSecond: String
    let tenths: String
}

enum FloatClockCurrentTimeFormatter {
    static func parts(for date: Date, calendar: Calendar = .current) -> FloatClockCurrentTimeParts {
        let components = calendar.dateComponents([.minute, .second, .nanosecond], from: date)
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        let tenths = (components.nanosecond ?? 0) / 100_000_000

        return FloatClockCurrentTimeParts(
            minuteSecond: String(format: "%02d:%02d", minute, second),
            tenths: String(tenths)
        )
    }
}
