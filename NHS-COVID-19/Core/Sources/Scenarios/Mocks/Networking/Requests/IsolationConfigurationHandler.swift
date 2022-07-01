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
              "indexCaseSinceSelfDiagnosisOnset": 6,
              "indexCaseSinceSelfDiagnosisUnknownOnset": 4,
              "contactCase": 11,
              "maxIsolation": 16,
              "indexCaseSinceTestResultEndDate": 6,
              "testResultPollingTokenRetentionPeriod": 28
            },
            "wales_v2": {
              "indexCaseSinceSelfDiagnosisOnset": 5,
              "indexCaseSinceSelfDiagnosisUnknownOnset": 5,
              "contactCase": 11,
              "maxIsolation": 16,
              "indexCaseSinceTestResultEndDate": 5,
              "testResultPollingTokenRetentionPeriod": 28
            }
        }
        """#))
        return Result.success(response)
    }
}
