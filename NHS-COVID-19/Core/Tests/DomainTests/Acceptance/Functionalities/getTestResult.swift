//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
@testable import Domain

func getTestResult(result: VirologyTestResult.TestResult, endDate: Date) -> String {
    let timestamp = ISO8601DateFormatter().string(from: endDate)
    return """
    {
        "diagnosisKeySubmissionToken": "6B162698-ADC5-47AF-8790-71ACF770FFAF",
        "testEndDate": "\(timestamp)",
        "testResult": "\(String(from: result))"
    }
    """
}

private extension String {
    init(from testResult: VirologyTestResult.TestResult) {
        switch testResult {
        case .negative:
            self.init("NEGATIVE")
        case .positive:
            self.init("POSITIVE")
        case .void:
            self.init("VOID")
        }
    }
}

