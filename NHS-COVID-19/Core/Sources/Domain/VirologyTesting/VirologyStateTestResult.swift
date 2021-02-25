//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct VirologyStateTestResult {
    var testResult: TestResult
    var testKitType: TestKitType?
    var endDate: Date
    var diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken?
    var requiresConfirmatoryTest: Bool
}

extension VirologyStateTestResult {
    var endDay: GregorianDay {
        GregorianDay(date: endDate, timeZone: .utc)
    }
}
