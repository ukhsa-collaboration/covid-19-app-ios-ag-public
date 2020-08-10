//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common

public struct RiskInfo: Codable, Equatable {
    var riskScore: Double
    var day: GregorianDay
}

extension RiskInfo {
    
    func isHigherPriority(than other: RiskInfo) -> Bool {
        if day > other.day { return true }
        if day < other.day { return false }
        return riskScore > other.riskScore
    }
    
}
