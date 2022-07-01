//
// Copyright © 2020 NHSX. All rights reserved.
//

import Security
@testable import Domain

struct MockTrustValidator: TrustValidating {
    var canAccept: Bool

    init(canAccept: Bool) {
        self.canAccept = canAccept
    }

    func canAccept(_ trust: SecTrust?) -> Bool {
        canAccept
    }
}
