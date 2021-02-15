//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct VirologyStateTestResult {
    var testResult: TestResult
    var testKitType: TestKitType?
    var endDate: Date
    var diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken?
    var requiresConfirmatoryTest: Bool
}
