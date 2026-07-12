import Combine
import Foundation

enum FloatClockFailure: Equatable, Sendable {
    case activitiesUnavailable
    case startFailed
    case stopFailed
}

@MainActor
final class FloatClockController: ObservableObject {
    @Published private(set) var isActive: Bool
    @Published private(set) var isInFlight: Bool = false
    @Published var failure: FloatClockFailure?

    private let activityClient: any FloatClockActivityClient

    init(activityClient: any FloatClockActivityClient = SystemFloatClockActivityClient()) {
        self.activityClient = activityClient
        isActive = activityClient.activeFloatClockCount > 0
    }

    func reconcile() {
        isActive = activityClient.activeFloatClockCount > 0
    }

    func setActive(_ requestedState: Bool) {
        guard !isInFlight else { return }
        Task {
            await requestActive(requestedState)
        }
    }

    func requestActive(_ requestedState: Bool) async {
        guard !isInFlight else { return }
        isInFlight = true
        defer { isInFlight = false }

        if requestedState {
            startIfNeeded()
        } else {
            do {
                try await activityClient.stopAll()
            } catch {
                failure = .stopFailed
            }
        }

        reconcile()
    }

    private func startIfNeeded() {
        guard activityClient.activitiesEnabled else {
            failure = .activitiesUnavailable
            return
        }

        guard activityClient.activeFloatClockCount == 0 else {
            return
        }

        do {
            try activityClient.start()
        } catch {
            failure = .startFailed
        }
    }
}
