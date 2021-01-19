//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct VirologyTestResultsHandler: RequestHandler {
    var paths = ["/virology-test/results"]
    
    var dataProvider: MockDataProvider
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        let daysAgo = dataProvider.testResultEndDateDaysAgo
        let date = GregorianDay.today.advanced(by: -daysAgo).startDate(in: .utc)
        let dateString = ISO8601DateFormatter().string(from: date)
        let testResult = MockDataProvider.testResults[dataProvider.receivedTestResult]
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
        "testEndDate": "\#(dateString)",
        "testResult": "\#(testResult)"
        }
        """#))
        return Result.success(response)
    }
}
