import Foundation
import Testing
@testable import FloatClock

struct FloatClockAttributesTests {
    @Test
    func contentStateRoundTrips() throws {
        let state = FloatClockAttributes.ContentState()

        let encoded = try JSONEncoder().encode(state)
        _ = try JSONDecoder().decode(FloatClockAttributes.ContentState.self, from: encoded)

        #expect(encoded.isEmpty == false)
    }
}
