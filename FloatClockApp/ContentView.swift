import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var controller = FloatClockController()

    var body: some View {
        VStack {
            Spacer()
            Toggle(
                "FloatClock",
                isOn: Binding(
                    get: { controller.isActive },
                    set: { controller.setActive($0) }
                )
            )
            .disabled(controller.isInFlight)
            .tint(.floatClockAccent)
            .accessibilityHint("Turns the FloatClock current-time Live Activity on or off.")
            .accessibilityIdentifier("floatClockToggle")
            .fixedSize()
            Spacer()
        }
        .padding()
        .task {
            controller.reconcile()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                controller.reconcile()
            }
        }
        .alert(
            FloatClockFailureAlert.title(for: controller.failure),
            isPresented: Binding(
                get: { controller.failure != nil },
                set: { isPresented in
                    if !isPresented { controller.failure = nil }
                }
            )
        ) {
            Button("OK") { controller.failure = nil }
        } message: {
            Text(FloatClockFailureAlert.message(for: controller.failure))
        }
    }
}

enum FloatClockFailureAlert {
    static func title(for failure: FloatClockFailure?) -> LocalizedStringKey {
        switch failure {
        case .activitiesUnavailable:
            return "FloatClock Is Unavailable"
        case .startFailed, .stopFailed:
            return "FloatClock Couldn’t Update"
        case nil:
            return ""
        }
    }

    static func message(for failure: FloatClockFailure?) -> LocalizedStringKey {
        switch failure {
        case .activitiesUnavailable:
            return "Live Activities are turned off. Enable them in Settings to use FloatClock."
        case .startFailed:
            return "FloatClock couldn’t start. The switch has returned to its actual state."
        case .stopFailed:
            return "FloatClock couldn’t stop. The switch has returned to its actual state."
        case nil:
            return ""
        }
    }
}

#Preview {
    ContentView()
}
