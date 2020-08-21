//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct RiskyVenueHandler: RequestHandler {
    var paths = ["/distribution/risky-venues"]
    
    var dataProvider: MockDataProvider
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        let riskyVenues = dataProvider.riskyVenueIDs.components(separatedBy: ",")
            .lazy
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { #"""
            {
            "id": "\#($0)",
            "riskyWindow": {
            "from": "2019-07-04T13:33:03Z",
            "until": "2029-07-04T23:59:03Z"
            }
            }
            """#
            }
            .joined(separator: ",")
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
