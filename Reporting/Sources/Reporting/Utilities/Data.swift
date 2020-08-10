//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension Data {
    var toString: String? {
        String(data: self, encoding: .utf8)
    }
}
