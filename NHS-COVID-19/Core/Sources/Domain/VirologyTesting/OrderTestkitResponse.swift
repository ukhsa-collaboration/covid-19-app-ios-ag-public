//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct OrderTestkitResponse: Equatable {
    var testOrderWebsite: URL
    var referenceCode: ReferenceCode
    var testResultPollingToken: PollingToken
    var diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken
}

public struct ReferenceCode: Equatable {
    public var value: String
}

public struct DiagnosisKeySubmissionToken: Equatable {
    var value: String
    public init(value: String) {
        self.value = value
    }
}

struct PollingToken: Equatable {
    var value: String
}
