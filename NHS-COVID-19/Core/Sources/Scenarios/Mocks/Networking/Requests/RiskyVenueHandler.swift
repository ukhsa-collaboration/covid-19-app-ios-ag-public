//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

enum MessageType: String, Codable {
    case m1 = "M1"
    case m2 = "M2"
}

struct RiskyVenueHandler: RequestHandler {
    var paths = ["/distribution/risky-venues"]
    
    var dataProvider: MockDataProvider
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        var riskyVenues = ""
        
        let mockedRiskyVenues: [MessageType: String] = [
            MessageType.m1: dataProvider.riskyVenueIDsWarnAndInform,
            MessageType.m2: dataProvider.riskyVenueIDsWarnAndBookTest,
        ]
        
        for (messageType, venues) in mockedRiskyVenues {
            if !riskyVenues.isEmpty {
                riskyVenues.append(",")
            }
            riskyVenues.append(
                venues.components(separatedBy: ",")
                    .lazy
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .map { #"""
                    {
                    "id": "\#($0)",
                    "riskyWindow": {
                    "from": "2019-07-04T13:33:03Z",
                    "until": "2029-07-04T23:59:03Z"
                    },
                    "messageType":"\#(messageType.rawValue)"
                    }
                    """#
                    }
                    .joined(separator: ",")
            )
        }
        let json = #"""
        {
        "venues" : [
        \#(riskyVenues)
        ]
        }
        """#
        return Result.success(.ok(with: .json(json)))
    }
}
