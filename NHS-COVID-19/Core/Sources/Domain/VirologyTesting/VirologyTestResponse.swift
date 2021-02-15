//
// Copyright © 2020 NHSX. All rights reserved.
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
}

struct VirologyTestResult: Equatable {
    enum TestResult: Equatable {
        case positive
        case negative
        case void
    }
    
    enum TestKitType: Equatable {
        case labResult
        case rapidResult
        case rapidSelfReported
    }
    
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
}
