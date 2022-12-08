//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct VirologyStateTestResult {
    var testResult: UnacknowledgedTestResult
    var testKitType: TestKitType?
    var endDate: Date
    var diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken?
    var requiresConfirmatoryTest: Bool
    var shouldOfferFollowUpTest: Bool
    var confirmatoryDayLimit: Int?
    var selfReported: Bool = false
}

extension VirologyStateTestResult {
    var endDay: GregorianDay {
        GregorianDay(date: endDate, timeZone: .utc)
    }
}
