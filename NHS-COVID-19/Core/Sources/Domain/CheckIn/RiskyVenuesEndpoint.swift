//
// Copyright © 2020 NHSX. All rights reserved.
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
    }
    
    var venues: [Venue]
}

private extension RiskyVenue {
    
    init(_ venue: Payload.Venue) {
        self.init(
            id: venue.id,
            riskyInterval: DateInterval(venue.riskyWindow)
        )
    }
    
}

private extension DateInterval {
    
    init(_ window: Payload.RiskyWindow) {
        self.init(start: window.from, end: window.until)
    }
    
}
