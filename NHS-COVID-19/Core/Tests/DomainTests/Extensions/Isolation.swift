//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
@testable import Domain

extension Isolation {
    // Shim to help with testing.
    // We’d like to keep `optOutOfIsolationDay` non-defaulted in production code to help detect issues early.
    init(fromDay: LocalDay, untilStartOfDay: LocalDay, reason: Isolation.Reason) {
        self.init(fromDay: fromDay, untilStartOfDay: untilStartOfDay, reason: reason, optOutOfContactIsolationInfo: nil)
    }
}
