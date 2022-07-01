//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension Data {

    var emoji: String {
        let range = 0x1F600 ... 0x1F64F
        let hash = Int(reduce(0, ^))
        let (offset, _) = hash.remainderReportingOverflow(dividingBy: range.count)
        let index = range.lowerBound + offset
        guard let scalar = UnicodeScalar(index) else { return "❓" }
        return String(scalar)
    }

}
