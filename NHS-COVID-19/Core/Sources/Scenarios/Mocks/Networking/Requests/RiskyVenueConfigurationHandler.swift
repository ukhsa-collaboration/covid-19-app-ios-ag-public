//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct RiskyVenueConfigurationHandler: RequestHandler {
    var paths = ["/distribution/risky-venue-configuration"]
    
    var dataProvider: MockDataProvider
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        let response = HTTPResponse.ok(with: .json(#"""
        {
        "durationDays": {
        "optionToBookATest": \#(dataProvider.optionToBookATest)
        }
        }
        """#))
        return Result.success(response)
    }
}
