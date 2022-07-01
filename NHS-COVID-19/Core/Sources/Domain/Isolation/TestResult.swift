//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

/// Result of a test stored to be used as part of isolation logic.
/// - seealso: `UnacknowledgedTestResult`
public enum TestResult: Equatable {
    case positive
    case negative
}

/// Result of a test that is received but is not yet acknowledged to be used as part of isolation logic.
///
/// Some of the tests will be fully removed after they are acknowledged, which is why this type has more cases than
/// - seealso: `TestResult`
public enum UnacknowledgedTestResult: Equatable {
    case positive
    case plod
    case negative
    case void
}

extension TestResult {

    init?(_ testResult: UnacknowledgedTestResult) {
        switch testResult {
        case .positive:
            self = .positive
        case .negative:
            self = .negative
        case .plod, .void:
            return nil
        }
    }

}
