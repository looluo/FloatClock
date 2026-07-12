import ActivityKit
import Foundation

@MainActor
protocol FloatClockActivityClient {
    var activitiesEnabled: Bool { get }
    var activeFloatClockCount: Int { get }

    func start() throws
    func stopAll() async throws
}

@MainActor
struct SystemFloatClockActivityClient: FloatClockActivityClient {
    var activitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    var activeFloatClockCount: Int {
        Activity<FloatClockAttributes>.activities.count
    }

    func start() throws {
        let content = ActivityContent(
            state: FloatClockAttributes.ContentState(),
            staleDate: nil
        )

        _ = try Activity.request(
            attributes: FloatClockAttributes(),
            content: content,
            pushType: nil
        )
    }

    func stopAll() async throws {
        let finalContent = ActivityContent(
            state: FloatClockAttributes.ContentState(),
            staleDate: nil
        )

        for activity in Activity<FloatClockAttributes>.activities {
            await activity.end(finalContent, dismissalPolicy: .immediate)
        }
    }
}
