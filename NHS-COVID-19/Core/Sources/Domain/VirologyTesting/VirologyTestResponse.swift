//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

enum VirologyTestResponse: Equatable {
    case receivedResult(VirologyTestResult)
    case noResultYet
}

struct VirologyTestResult: Equatable {
    enum TestResult: Equatable {
        case positive
        case negative
        case void
    }
    
    var testResult: TestResult
    var endDate: Date
}

struct LinkVirologyTestResultResponse: Equatable {
    var virologyTestResult: VirologyTestResult
    var diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken
}
