//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import ExposureNotification

public protocol ExposureRiskCalculating {
    func riskInfo(for exposureInfo: [ExposureNotificationExposureInfo]) -> RiskInfo?
    func createExposureNotificationConfiguration() -> ENExposureConfiguration
}

public struct ExposureRiskCalculator: ExposureRiskCalculating {
    var configuration: ExposureDetectionConfiguration
    
    public init(configuration: ExposureDetectionConfiguration) {
        self.configuration = configuration
    }
    
    public func isConsideredRisky(riskScore: Double) -> Bool {
        riskScore > configuration.riskThreshold
    }
    
    func risk(for exposureInfo: ExposureNotificationExposureInfo) -> Double {
        let durations = exposureInfo.attenuationDurations.map { $0.doubleValue }
        let weightedDurations = zip(durations, configuration.durationBucketWeights).map(*)
        
        return weightedDurations.reduce(0, +)
    }
    
    public func riskInfo(for exposureInfo: [ExposureNotificationExposureInfo]) -> RiskInfo? {
        let riskScore = exposureInfo
            .map {
                RiskInfo(
                    riskScore: risk(for: $0),
                    day: GregorianDay(date: $0.date, timeZone: Calendar.utc.timeZone)
                )
            }
            .filter { isConsideredRisky(riskScore: $0.riskScore) }
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
