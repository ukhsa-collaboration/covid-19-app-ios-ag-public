//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct LinkVirologyTestResultHandler: RequestHandler {
    var paths = ["/virology-test/v2/cta-exchange"]
    
    var dataProvider: MockDataProvider
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        let daysAgo = dataProvider.testResultEndDateDaysAgo
        let confirmatoryDayLimit = dataProvider.confirmatoryDayLimit
        let date = GregorianDay.today.advanced(by: -daysAgo).startDate(in: .utc)
        let dateString = ISO8601DateFormatter().string(from: date)
        let testResult = MockDataProvider.testResults[dataProvider.receivedTestResult]
        let testType = MockDataProvider.testKitType[dataProvider.testKitType]
        let diagnosisKeySubmissionSupported = dataProvider.keySubmissionSupported
        let diagnosisKeySubmissionToken = dataProvider.keySubmissionSupported ? UUID().uuidString : nil
        let requiresConfirmatoryTest = dataProvider.requiresConfirmatoryTest
        let shouldOfferFollowUpTest = dataProvider.shouldOfferFollowUpTest
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
        "testEndDate": "\#(dateString)",
        "testResult": "\#(testResult)",
        "testKit":"\#(testType)",
        \#(value(named: "diagnosisKeySubmissionToken", content: diagnosisKeySubmissionToken)),
        "diagnosisKeySubmissionSupported": \#(diagnosisKeySubmissionSupported),
        "requiresConfirmatoryTest": \#(requiresConfirmatoryTest),
        "shouldOfferFollowUpTest": \#(shouldOfferFollowUpTest),
        \#(value(named: "confirmatoryDayLimit", content: confirmatoryDayLimit)),
        }
        """#))
        return Result.success(response)
    }
}
