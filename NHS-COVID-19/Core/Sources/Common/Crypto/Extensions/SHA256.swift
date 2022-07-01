//
// Copyright © 2020 NHSX. All rights reserved.
//

import CryptoKit
import Foundation

extension SHA256 {

    static func hash(from components: [Data]) -> SHA256Digest {
        mutating(SHA256()) { sha in
            components.forEach {
                sha.update(data: $0)
            }
        }.finalize()
    }

}
