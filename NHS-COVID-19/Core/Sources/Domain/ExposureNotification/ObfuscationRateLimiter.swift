//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common

protocol ObfuscationRateLimiting {
    var allow: Bool { get }
}

struct ObfuscationRateLimiter: ObfuscationRateLimiting {
    var allow: Bool {
        Int.random(in: 0...9) == 0
    }
}
