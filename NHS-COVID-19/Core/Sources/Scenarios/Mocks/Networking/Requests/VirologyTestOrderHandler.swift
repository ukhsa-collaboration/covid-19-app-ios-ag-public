//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct VirologyTestOrderHandler: RequestHandler {
    var paths = ["/virology-test/v2/order"]

    var dataProvider: MockDataProvider

    var response: Result<HTTPResponse, HTTPRequestError> {
        let referenceCode = dataProvider.testReferenceCode
        let websiteURL = URL(string: dataProvider.orderTestWebsite) ?? URL(string: "https://example.com")!

        let response = HTTPResponse.ok(with: .json(#"""
        {
        "websiteUrlWithQuery": "\#(websiteURL)",
        "tokenParameterValue": "\#(referenceCode)",
        "testResultPollingToken" : "\#(UUID().uuidString)",
        "diagnosisKeySubmissionToken": "\#(UUID().uuidString)"
        }
        """#))
        return Result.success(response)
    }
}
