//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct VirologyStateTestResult {
    var testResult: TestResult
    var testKitType: TestKitType?
    var endDate: Date
    var diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken?
    var requiresConfirmatoryTest: Bool
    var confirmatoryDayLimit: Int?
}

extension VirologyStateTestResult {
    var endDay: GregorianDay {
        GregorianDay(date: endDate, timeZone: .utc)
    }
}
