//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct LookUpHandler: RequestHandler {
    var paths = ["/lookup"]

    var dataProvider: MockDataProvider

    private let productionAppBundleId = "uk.nhs.covid19.production"

    var response: Result<HTTPResponse, HTTPRequestError> {
        let response = HTTPResponse.ok(with: .json(#"""
        {
        "results": [
        {
        "bundleId": "\#(productionAppBundleId)",
        "version": "\#(dataProvider.latestAppVersion)"
        }
        ]
        }
        """#))
        return Result.success(response)
    }
}
