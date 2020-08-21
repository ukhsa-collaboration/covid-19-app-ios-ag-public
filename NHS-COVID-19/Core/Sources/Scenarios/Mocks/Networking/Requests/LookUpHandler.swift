//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct LookUpHandler: RequestHandler {
    var paths = ["/lookup"]
    
    var dataProvider: MockDataProvider
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        let response = HTTPResponse.ok(with: .json(#"""
        {
        "results": [
        {
        "bundleId": "\#(Bundle.main.bundleIdentifier!)",
        "version": "\#(dataProvider.latestAppVersion)"
        }
        ]
        }
        """#))
        return Result.success(response)
    }
}
