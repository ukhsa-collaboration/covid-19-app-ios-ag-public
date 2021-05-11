//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public enum TestKitType: String, Codable, Equatable {
    case labResult
    case rapidResult
    case rapidSelfReported
    
    init(_ virologyTestKit: VirologyTestResult.TestKitType) {
        switch virologyTestKit {
        case .labResult:
            self = .labResult
        case .rapidResult:
            self = .rapidResult
        case .rapidSelfReported:
            self = .rapidSelfReported
        }
    }
}
