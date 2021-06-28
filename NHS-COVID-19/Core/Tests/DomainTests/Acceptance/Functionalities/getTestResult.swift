//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
@testable import Domain

func getTestResult(result: VirologyTestResult.TestResult,
                   testKitType: VirologyTestResult.TestKitType,
                   endDate: Date,
                   diagnosisKeySubmissionSupported: Bool,
                   requiresConfirmatoryTest: Bool,
                   confirmatoryDayLimit: Int?) -> String {
    
    let timestamp = ISO8601DateFormatter().string(from: endDate)
    return """
    {
        "diagnosisKeySubmissionToken": "6B162698-ADC5-47AF-8790-71ACF770FFAF",
        "requiresConfirmatoryTest": \(requiresConfirmatoryTest),
        "testEndDate": "\(timestamp)",
        "testResult": "\(String(from: result))",
        "testKit": "\(String(from: testKitType))",
        "diagnosisKeySubmissionSupported": \(diagnosisKeySubmissionSupported),
        "confirmatoryDayLimit": \((confirmatoryDayLimit != nil) ? String(describing: confirmatoryDayLimit!) : "null")
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
        case .plod:
            self.init("PLOD")
        }
    }
}

private extension String {
    init(from testKitType: VirologyTestResult.TestKitType) {
        switch testKitType {
        case .labResult:
            self.init("LAB_RESULT")
        case .rapidResult:
            self.init("RAPID_RESULT")
        case .rapidSelfReported:
            self.init("RAPID_SELF_REPORTED")
        }
    }
}
