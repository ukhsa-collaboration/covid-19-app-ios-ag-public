//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

enum VirologyTestResponse: Equatable {
    case receivedResult(PollVirologyTestResultResponse)
    case noResultYet
}

struct PollVirologyTestResultResponse: Equatable {
    var virologyTestResult: VirologyTestResult
    var diagnosisKeySubmissionSupport: Bool
    var requiresConfirmatoryTest: Bool
    var shouldOfferFollowUpTest: Bool
    var confirmatoryDayLimit: Int?
}

struct VirologyTestResult: Equatable {
    typealias TestResult = UnacknowledgedTestResult
    typealias TestKitType = Domain.TestKitType
    
    var testResult: TestResult
    var testKitType: TestKitType
    var endDate: Date
}

enum DiagnosisKeySubmissionSupport: Equatable {
    case supported(diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken)
    case notSupported
}

struct LinkVirologyTestResultResponse: Equatable {
    var virologyTestResult: VirologyTestResult
    var diagnosisKeySubmissionSupport: DiagnosisKeySubmissionSupport
    var requiresConfirmatoryTest: Bool
    var shouldOfferFollowUpTest: Bool
    var confirmatoryDayLimit: Int?
}
