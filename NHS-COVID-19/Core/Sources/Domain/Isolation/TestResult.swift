//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public enum TestResult: String, Codable, Equatable {
    case positive
    case negative
    case void
    
    init(_ virologyTestResult: VirologyTestResult.TestResult) {
        switch virologyTestResult {
        case .positive:
            self = .positive
        case .negative:
            self = .negative
        case .void:
            self = .void
        }
    }
}
