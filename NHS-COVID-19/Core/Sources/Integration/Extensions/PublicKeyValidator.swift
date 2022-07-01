//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation
import ProductionConfiguration

extension PublicKeyValidator {

    convenience init(pins: [PublicKeyPin]) {
        self.init(trustedKeyHashes: Set(pins.lazy.map { $0.base64EncodedString }))
    }

}
