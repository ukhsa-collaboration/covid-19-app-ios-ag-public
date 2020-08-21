//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct VirologyTestResultsHandler: RequestHandler {
    var paths = ["/virology-test/results"]
    
    var dataProvider: MockDataProvider
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        let date = "2020-04-23T00:00:00.0000000Z"
        let testResult = MockDataProvider.testResults[dataProvider.receivedTestResult]
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
        "testEndDate": "\#(date)",
        "testResult": "\#(testResult)"
        }
        """#))
        return Result.success(response)
    }
}
