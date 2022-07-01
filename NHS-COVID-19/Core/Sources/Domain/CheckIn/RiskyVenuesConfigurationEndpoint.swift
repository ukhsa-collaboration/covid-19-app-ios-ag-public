//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct RiskyVenuesConfigurationEndpoint: HTTPEndpoint {

    func request(for input: Void) throws -> HTTPRequest {
        .get("/distribution/risky-venue-configuration")
    }

    func parse(_ response: HTTPResponse) throws -> RiskyVenueConfiguration {
        let decoder = JSONDecoder()
        let payload = try decoder.decode(Payload.self, from: response.body.content)
        return try RiskyVenueConfiguration(from: payload)
    }
}

private struct Payload: Decodable {
    var durationDays: DurationDays

    struct DurationDays: Decodable {
        var optionToBookATest: Int
    }
}

private extension RiskyVenueConfiguration {
    init(from payload: Payload) throws {
        let durations = payload.durationDays
        self.init(optionToBookATest: DayDuration(durations.optionToBookATest))
    }
}
