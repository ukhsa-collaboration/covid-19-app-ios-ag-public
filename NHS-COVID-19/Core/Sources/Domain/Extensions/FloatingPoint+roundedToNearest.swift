//
// Copyright © 2020 NHSX. All rights reserved.
//

extension FloatingPoint {
    func rounded(_ rule: FloatingPointRoundingRule, toNearest nearest: Self) -> Self {
        (self / nearest).rounded(rule) * nearest
    }
}
