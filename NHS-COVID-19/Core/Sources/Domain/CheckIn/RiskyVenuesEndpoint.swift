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
    enum MessageType: String, Codable {
        case m1 = "M1"
        case m2 = "M2"
        case m3 = "M3"
    }
    
    struct RiskyWindow: Codable {
        var from: Date
        var until: Date
    }
    
    struct Venue: Codable {
        var id: String
        var riskyWindow: RiskyWindow
        var messageType: MessageType?
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
    
    init(_ messageType: Payload.MessageType?) {
        switch messageType {
        case .m1:
            self = .inform
        case .m2:
            self = .isolate
        case .m3:
            self = .inform
        case .none:
            self = .inform
        }
    }
}
