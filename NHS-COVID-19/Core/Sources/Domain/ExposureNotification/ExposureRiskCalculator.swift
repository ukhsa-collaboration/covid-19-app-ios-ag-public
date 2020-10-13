//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import ExposureNotification

public protocol ExposureRiskCalculating {
    func riskInfo(for exposureInfo: [ExposureNotificationExposureInfo]) -> ExposureRiskInfo?
    func createExposureNotificationConfiguration() -> ENExposureConfiguration
}

public struct ExposureRiskCalculator: ExposureRiskCalculating {
    private let configuration: ExposureDetectionConfiguration
    private let infectiousnessFactorCalculator: InfectiousnessFactorCalculating
    
    init(
        configuration: ExposureDetectionConfiguration,
        infectiousnessFactorCalculator: InfectiousnessFactorCalculating = InfectiousnessFactorCalculator()
    ) {
        self.configuration = configuration
        self.infectiousnessFactorCalculator = infectiousnessFactorCalculator
    }
    
    static func withConfiguration(_ configuration: ExposureDetectionConfiguration) -> ExposureRiskCalculator {
        return ExposureRiskCalculator(configuration: configuration)
    }
    
    public func isConsideredRisky(riskScore: Double) -> Bool {
        riskScore > configuration.riskThreshold
    }
    
    func risk(for exposureInfo: ExposureNotificationExposureInfo) -> Double {
        let durations = exposureInfo.attenuationDurations.map { $0.doubleValue }
        let weightedDurations = zip(durations, configuration.durationBucketWeights).map(*)
        let weightedAttenuationScore = weightedDurations.reduce(0, +)
        
        let daysFromOnset: Int = ENTemporaryExposureKey.maxTransmissionRiskLevel - Int(exposureInfo.transmissionRiskLevel)
        let infectiousnessFactor = infectiousnessFactorCalculator.infectiousnessFactor(for: daysFromOnset)
        
        return weightedAttenuationScore * infectiousnessFactor
    }
    
    public func riskInfo(for exposureInfo: [ExposureNotificationExposureInfo]) -> ExposureRiskInfo? {
        let riskScore = exposureInfo
            .map { exposure -> ExposureRiskInfo in
                let riskScore = risk(for: exposure)
                return ExposureRiskInfo(
                    riskScore: riskScore,
                    day: GregorianDay(date: exposure.date, timeZone: .utc),
                    isConsideredRisky: isConsideredRisky(riskScore: riskScore)
                )
            }
            .max { $1.isHigherPriority(than: $0) }
        
        return riskScore
    }
    
    public func createExposureNotificationConfiguration() -> ENExposureConfiguration {
        let enConfiguration = ENExposureConfiguration()
        enConfiguration.transmissionRiskWeight = configuration.transmitionWeight
        enConfiguration.durationWeight = configuration.durationWeight
        enConfiguration.attenuationWeight = configuration.attenuationWeight
        enConfiguration.daysSinceLastExposureWeight = configuration.daysWeight
        enConfiguration.transmissionRiskLevelValues = configuration.transmition.map { NSNumber(value: $0) }
        enConfiguration.durationLevelValues = configuration.duration.map { NSNumber(value: $0) }
        enConfiguration.daysSinceLastExposureLevelValues = configuration.daysSinceLastExposure.map { NSNumber(value: $0) }
        enConfiguration.attenuationLevelValues = configuration.attenuation.map { NSNumber(value: $0) }
        enConfiguration.metadata = ["attenuationDurationThresholds": configuration.thresholds.map { NSNumber(value: $0) }]
        return enConfiguration
    }
}
