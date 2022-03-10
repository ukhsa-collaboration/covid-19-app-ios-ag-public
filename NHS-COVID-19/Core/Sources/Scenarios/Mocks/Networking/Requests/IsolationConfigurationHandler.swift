//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Foundation

struct IsolationConfigurationHandler: RequestHandler {
    var paths = ["/distribution/self-isolation"]
    
    var dataProvider: MockDataProvider
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        let response = HTTPResponse.ok(with: .json(#"""
          {
            "england": {
              "indexCaseSinceSelfDiagnosisOnset": 11,
              "indexCaseSinceSelfDiagnosisUnknownOnset": 9,
              "contactCase": 11,
              "maxIsolation": 21,
              "indexCaseSinceTestResultEndDate": 11,
              "testResultPollingTokenRetentionPeriod": 28
            },
            "wales": {
              "indexCaseSinceSelfDiagnosisOnset": 11,
              "indexCaseSinceSelfDiagnosisUnknownOnset": 9,
              "contactCase": 11,
              "maxIsolation": 21,
              "indexCaseSinceTestResultEndDate": 11,
              "testResultPollingTokenRetentionPeriod": 28
            }
        }
        """#))
        return Result.success(response)
    }
}
