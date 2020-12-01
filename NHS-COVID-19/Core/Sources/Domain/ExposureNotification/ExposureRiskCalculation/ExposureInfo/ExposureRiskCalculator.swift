//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import ExposureNotification

public protocol ExposureRiskCalculating {
    func riskInfo(for exposureInfo: [ExposureNotificationExposureInfo], configuration: ExposureDetectionConfiguration) -> ExposureRiskInfo?
}

public struct ExposureRiskCalculator: ExposureRiskCalculating {
    private static let riskScoreVersion = 1
    private let infectiousnessFactorCalculator: InfectiousnessFactorCalculating
    
    init(
        infectiousnessFactorCalculator: InfectiousnessFactorCalculating = InfectiousnessFactorCalculator()
    ) {
        self.infectiousnessFactorCalculator = infectiousnessFactorCalculator
    }
    
    func risk(for exposureInfo: ExposureNotificationExposureInfo, durationBucketWeights: [Double]) -> Double {
        let durations = exposureInfo.attenuationDurations.map { $0.doubleValue }
        let weightedDurations = zip(durations, durationBucketWeights).map(*)
        let weightedAttenuationScore = weightedDurations.reduce(0, +)
        
        let daysFromOnset: Int = ENTemporaryExposureKey.maxTransmissionRiskLevel - Int(exposureInfo.transmissionRiskLevel)
        let infectiousnessFactor = infectiousnessFactorCalculator.infectiousnessFactor(for: daysFromOnset)
        
        return weightedAttenuationScore * infectiousnessFactor
    }
    
    public func riskInfo(for exposureInfo: [ExposureNotificationExposureInfo], configuration: ExposureDetectionConfiguration) -> ExposureRiskInfo? {
        return exposureInfo
            .map {
                let riskScore = risk(for: $0, durationBucketWeights: configuration.durationBucketWeights)
                return ExposureRiskInfo(
                    riskScore: riskScore,
                    riskScoreVersion: Self.riskScoreVersion,
                    day: GregorianDay(date: $0.date, timeZone: .utc),
                    riskThreshold: configuration.riskThreshold
                )
            }
            .max { $1.isHigherPriority(than: $0) }
    }
}
