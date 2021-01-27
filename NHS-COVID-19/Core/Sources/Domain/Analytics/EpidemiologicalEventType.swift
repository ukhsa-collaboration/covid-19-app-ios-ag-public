//
// Copyright © 2020 NHSX. All rights reserved.
//

enum EpidemiologicalEventType: String, Codable {
    case exposureWindow
    case exposureWindowPositiveTest
}

enum TestType: String, Codable {
    case unknown
    case labResult = "LAB_RESULT"
    case rapidResult = "RAPID_RESULT"
    case rapidSelfReported = "RAPID_SELF_REPORTED"
}

extension TestType {
    init(from testKitType: TestKitType?) {
        switch testKitType {
        case .labResult: self = .labResult
        case .rapidResult: self = .rapidResult
        case .rapidSelfReported: self = .rapidSelfReported
        case .none: self = .unknown
        }
    }
}
