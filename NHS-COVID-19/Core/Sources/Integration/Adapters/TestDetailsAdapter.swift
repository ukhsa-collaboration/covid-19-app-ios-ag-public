//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Interface

extension Interface.TestResult {
    init?(domainTestResult: Domain.TestResult) {
        switch domainTestResult {
        case .positive:
            self = .positive
        case .negative:
            self = .negative
        case .void:
            self = .void
        case .plod:
            return nil
            
        }
    }
}

extension Interface.TestKitType {
    init(domainTestKitType: Domain.TestKitType) {
        switch domainTestKitType {
        case .rapidResult:
            self = .rapidResult
        case .labResult:
            self = .labResult
        case .rapidSelfReported:
            self = .rapidSelfReported
        }
    }
}
