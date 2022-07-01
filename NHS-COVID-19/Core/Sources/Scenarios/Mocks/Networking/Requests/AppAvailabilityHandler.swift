//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct AppAvailabilityHandler: RequestHandler {
    var paths = ["/distribution/availability-ios"]

    var dataProvider: MockDataProvider

    var response: Result<HTTPResponse, HTTPRequestError> {
        let response = HTTPResponse.ok(with: .json(#"""
        {
        "minimumOSVersion": {
        "value": "\#(dataProvider.minimumOSVersion)",
        "description": {
        "en-GB": "[Placeholder] this copy will be provided by the backend."
        }
        },
        "minimumAppVersion": {
        "value": "\#(dataProvider.minimumAppVersion)",
        "description": {
        "en-GB": "[Placeholder] this copy will be provided by the backend."
        }
        },
        "recommendedAppVersion": {
        "value": "\#(dataProvider.recommendedAppVersion)",
        "title": {
        "en-GB": "[Placeholder] this copy will be provided by the backend."
        },
        "description": {
        "en-GB": "[Placeholder] this copy will be provided by the backend."
        }
        },
        "recommendedOSVersion": {
        "value": "\#(dataProvider.recommendedOSVersion)",
        "title": {
        "en-GB": "[Placeholder] this copy will be provided by the backend."
        },
        "description": {
        "en-GB": "[Placeholder] this copy will be provided by the backend."
        }
        },
        }
        """#))
        return Result.success(response)
    }
}
