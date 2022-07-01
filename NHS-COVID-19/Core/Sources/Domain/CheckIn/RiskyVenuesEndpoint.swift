//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct RiskyVenuesEndpoint: HTTPEndpoint {

    func request(for input: Void) throws -> HTTPRequest {
        .get("/distribution/risky-venues")
    }

    func parse(_ response: HTTPResponse) throws -> [RiskyVenue] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .appNetworking
        return try decoder.decode(Payload.self, from: response.body.content)
            .venues
            .map(RiskyVenue.init)
    }

}

private struct Payload: Codable {
    struct RiskyWindow: Codable {
        var from: Date
        var until: Date
    }

    struct Venue: Codable {
        var id: String
        var riskyWindow: RiskyWindow
        var messageType: String
    }

    var venues: [Venue]
}

private extension RiskyVenue {

    init(_ venue: Payload.Venue) {
        self.init(
            id: venue.id,
            riskyInterval: DateInterval(venue.riskyWindow),
            messageType: MessageType(venue.messageType)
        )
    }

}

private extension DateInterval {

    init(_ window: Payload.RiskyWindow) {
        self.init(start: window.from, end: window.until)
    }

}

private extension RiskyVenue.MessageType {

    init(_ messageType: String) {
        switch messageType {
        case "M1":
            self = .warnAndInform
        case "M2":
            self = .warnAndBookATest
        default:
            self = .warnAndInform
        }
    }
}
