import Foundation
import Testing
@testable import FloatClock

@MainActor
struct FloatClockControllerTests {
    @Test
    func turningOnStartsOneFloatClock() async {
        let client = FakeFloatClockActivityClient()
        let controller = FloatClockController(activityClient: client)

        await controller.requestActive(true)

        #expect(client.startCallCount == 1)
        #expect(client.activeFloatClockCount == 1)
        #expect(controller.isActive)
    }

    @Test
    func turningOnAgainDoesNotCreateADuplicate() async {
        let client = FakeFloatClockActivityClient()
        let controller = FloatClockController(activityClient: client)

        await controller.requestActive(true)
        await controller.requestActive(true)

        #expect(client.startCallCount == 1)
        #expect(controller.isActive)
    }

    @Test
    func turningOnWithAnExistingFloatClockDoesNotCreateADuplicate() async {
        let client = FakeFloatClockActivityClient()
        client.activeFloatClockCount = 1
        let controller = FloatClockController(activityClient: client)

        await controller.requestActive(true)

        #expect(client.startCallCount == 0)
        #expect(controller.isActive)
    }

    @Test
    func turningOffEndsAndDismissesTheActiveFloatClock() async {
        let client = FakeFloatClockActivityClient()
        client.activeFloatClockCount = 1
        let controller = FloatClockController(activityClient: client)

        await controller.requestActive(false)

        #expect(client.stopAllCallCount == 1)
        #expect(client.endedActivityCount == 1)
        #expect(client.activeFloatClockCount == 0)
        #expect(!controller.isActive)
    }

    @Test
    func turningOffCleansUpUnexpectedDuplicates() async {
        let client = FakeFloatClockActivityClient()
        client.activeFloatClockCount = 3
        let controller = FloatClockController(activityClient: client)

        await controller.requestActive(false)

        #expect(client.endedActivityCount == 3)
        #expect(client.activeFloatClockCount == 0)
        #expect(!controller.isActive)
    }

    @Test(arguments: [0, 1, 3])
    func launchReflectsActualActivityCount(_ activityCount: Int) {
        let client = FakeFloatClockActivityClient()
        client.activeFloatClockCount = activityCount

        let controller = FloatClockController(activityClient: client)

        #expect(controller.isActive == (activityCount > 0))
    }

    @Test
    func reconciliationReflectsExternalTerminationWithoutRestarting() {
        let client = FakeFloatClockActivityClient()
        client.activeFloatClockCount = 1
        let controller = FloatClockController(activityClient: client)
        client.activeFloatClockCount = 0

        controller.reconcile()

        #expect(!controller.isActive)
        #expect(client.startCallCount == 0)
    }

    // MARK: - Ticket 04: permission failures and rapid input

    @Test
    func turningOnWithDisabledAuthorizationLeavesStateOffAndSurfacesAFailure() async {
        let client = FakeFloatClockActivityClient()
        client.activitiesEnabled = false
        let controller = FloatClockController(activityClient: client)

        await controller.requestActive(true)

        #expect(client.startCallCount == 0)
        #expect(!controller.isActive)
        #expect(controller.failure == .activitiesUnavailable)
    }

    @Test
    func aFailedCreationReconcilesToOffAndSurfacesAFailure() async {
        let client = FakeFloatClockActivityClient()
        client.startShouldFail = true
        let controller = FloatClockController(activityClient: client)

        await controller.requestActive(true)

        #expect(client.startCallCount == 1)
        #expect(client.activeFloatClockCount == 0)
        #expect(!controller.isActive)
        #expect(controller.failure == .startFailed)
    }

    @Test
    func aFailedEndReconcilesToActualStateAndSurfacesAFailure() async {
        let client = FakeFloatClockActivityClient()
        client.activeFloatClockCount = 1
        client.stopAllShouldFail = true
        let controller = FloatClockController(activityClient: client)

        await controller.requestActive(false)

        #expect(client.stopAllCallCount == 1)
        #expect(client.activeFloatClockCount == 1)
        #expect(controller.isActive)
        #expect(controller.failure == .stopFailed)
    }

    @Test
    func theToggleIsInFlightWhileAStopOperationRuns() async {
        let client = FakeFloatClockActivityClient()
        client.activeFloatClockCount = 1
        client.holdNextStop = true
        let controller = FloatClockController(activityClient: client)

        async let stop: Void = controller.requestActive(false)
        await Self.awaitInFlight(controller)

        #expect(controller.isInFlight)

        client.releaseHeldStop()
        _ = await stop

        #expect(!controller.isInFlight)
        #expect(client.stopAllCallCount == 1)
        #expect(!controller.isActive)
    }

    private static func awaitInFlight(_ controller: FloatClockController) async {
        for _ in 0..<100 where !controller.isInFlight {
            await Task.yield()
        }
    }

    @Test
    func rapidInputWhileAnOperationIsInFlightIsIgnored() async {
        let client = FakeFloatClockActivityClient()
        client.activeFloatClockCount = 1
        client.holdNextStop = true
        let controller = FloatClockController(activityClient: client)

        async let firstStop: Void = controller.requestActive(false)
        await Self.awaitInFlight(controller)
        #expect(controller.isInFlight)

        // While the first stop is still in flight, rapid repeated input must not
        // start a second overlapping stop or a competing start.
        await controller.requestActive(false)
        await controller.requestActive(true)

        #expect(client.stopAllCallCount == 1)
        #expect(client.startCallCount == 0)
        #expect(controller.isInFlight)

        client.releaseHeldStop()
        _ = await firstStop

        #expect(client.stopAllCallCount == 1)
        #expect(client.startCallCount == 0)
        #expect(!controller.isActive)
    }
}

@MainActor
private final class FakeFloatClockActivityClient: FloatClockActivityClient {
    var activitiesEnabled = true
    var activeFloatClockCount = 0
    var startShouldFail = false
    var stopAllShouldFail = false
    var holdNextStop = false
    private(set) var startCallCount = 0
    private(set) var stopAllCallCount = 0
    private(set) var endedActivityCount = 0
    private var stopGate: CheckedContinuation<Void, Never>?

    func start() throws {
        startCallCount += 1
        if startShouldFail {
            throw FloatClockActivityStubError.failure
        }
        activeFloatClockCount = 1
    }

    func stopAll() async throws {
        stopAllCallCount += 1
        if holdNextStop {
            holdNextStop = false
            await withCheckedContinuation { continuation in
                stopGate = continuation
            }
        }
        if stopAllShouldFail {
            throw FloatClockActivityStubError.failure
        }
        endedActivityCount += activeFloatClockCount
        activeFloatClockCount = 0
    }

    func releaseHeldStop() {
        stopGate?.resume()
        stopGate = nil
    }
}

private enum FloatClockActivityStubError: Error {
    case failure
}
