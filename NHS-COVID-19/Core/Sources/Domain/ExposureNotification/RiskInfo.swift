//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common

protocol RiskData {
    var riskScore: Double { get }
    var day: GregorianDay { get }
}

public struct RiskInfo: Codable, Equatable, RiskData {
    var riskScore: Double
    var day: GregorianDay
}

public struct ExposureRiskInfo: RiskData {
    var riskScore: Double
    var day: GregorianDay
    var isConsideredRisky: Bool
}

extension RiskData {
    
    func isHigherPriority(than other: RiskData) -> Bool {
        if day > other.day { return true }
        if day < other.day { return false }
        return riskScore > other.riskScore
    }
    
}
