//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common

protocol RiskData {
    var riskScore: Double { get }
    var riskScoreVersion: Int { get }
    var day: GregorianDay { get }
    var isConsideredRisky: Bool { get }
}

public struct RiskInfo: Codable, Equatable, RiskData {
    var riskScore: Double
    var riskScoreVersion: Int
    var day: GregorianDay
    var isConsideredRisky: Bool {
        true
    }
    
    private enum CodingKeys: String, CodingKey {
        case riskScore
        case riskScoreVersion
        case day
    }
    
    init(riskScore: Double, riskScoreVersion: Int, day: GregorianDay) {
        self.riskScore = riskScore
        self.riskScoreVersion = riskScoreVersion
        self.day = day
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        riskScore = try container.decode(Double.self, forKey: .riskScore)
        riskScoreVersion = try container.decodeIfPresent(Int.self, forKey: .riskScoreVersion) ?? 1
        day = try container.decode(GregorianDay.self, forKey: .day)
    }
}

public struct ExposureRiskInfo: RiskData {
    var riskScore: Double
    var riskScoreVersion: Int
    var day: GregorianDay
    var isConsideredRisky: Bool
    
    var shouldShowDontWorryNotification: Bool {
        riskScoreVersion < 2
    }
}

extension ExposureRiskInfo {
    init(riskScore: Double, riskScoreVersion: Int, day: GregorianDay, riskThreshold: Double) {
        self.riskScore = riskScore
        self.riskScoreVersion = riskScoreVersion
        self.day = day
        self.isConsideredRisky = riskScore >= riskThreshold
    }
}

extension RiskData {
    
    func isHigherPriority(than other: RiskData) -> Bool {
        if isConsideredRisky && !other.isConsideredRisky { return true }
        if !isConsideredRisky && other.isConsideredRisky { return false }
        if day > other.day { return true }
        if day < other.day { return false }
        return riskScore > other.riskScore
    }
    
}
