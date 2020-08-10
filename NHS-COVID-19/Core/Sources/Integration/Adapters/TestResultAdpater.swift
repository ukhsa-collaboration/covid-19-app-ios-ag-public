//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Interface

extension Interface.TestResult {
    init(domainTestResult: Domain.TestResult) {
        switch domainTestResult {
        case .positive:
            self = .positive
        case .negative:
            self = .negative
        }
    }
}
