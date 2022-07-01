//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Domain

class SandboxPostcodeValidator: PostcodeValidating {
    func isValid(_ postcode: Postcode) -> Bool {
        true
    }

    func country(for postcode: Postcode) -> Country? {
        .england
    }
}
