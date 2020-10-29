//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import RiskScore

public struct ExposureDetectionConfiguration {
    var transmitionWeight: Double
    var durationWeight: Double
    var attenuationWeight: Double
    var daysWeight: Double
    
    var transmition: [Int]
    var duration: [Int]
    var daysSinceLastExposure: [Int]
    var attenuation: [Int]
    
    var thresholds: [Int]
    
    var durationBucketWeights: [Double]
    
    var riskThreshold: Double
    
    var daysSinceOnsetToInfectiousness: [Int]
    
    var infectiousnessWeights: [Double]
    
    var reportTypeWhenMissing: Int
    
    var v2RiskThreshold: Double
    
    var riskScoreCalculatorConfig: RiskScoreCalculatorConfiguration
    
    public init(
        transmitionWeight: Double,
        durationWeight: Double,
        attenuationWeight: Double,
        daysWeight: Double,
        transmition: [Int],
        duration: [Int],
        daysSinceLastExposure: [Int],
        attenuation: [Int],
        thresholds: [Int],
        durationBucketWeights: [Double],
        riskThreshold: Double,
        daysSinceOnsetToInfectiousness: [Int],
        infectiousnessWeights: [Double],
        reportTypeWhenMissing: Int,
        v2RiskThreshold: Double,
        riskScoreCalculatorConfig: RiskScoreCalculatorConfiguration
    ) {
        self.transmitionWeight = transmitionWeight
        self.durationWeight = durationWeight
        self.attenuationWeight = attenuationWeight
        self.daysWeight = daysWeight
        
        self.transmition = transmition
        self.duration = duration
        self.daysSinceLastExposure = daysSinceLastExposure
        self.attenuation = attenuation
        self.thresholds = thresholds
        
        self.durationBucketWeights = durationBucketWeights
        self.riskThreshold = riskThreshold
        
        self.daysSinceOnsetToInfectiousness = daysSinceOnsetToInfectiousness
        self.infectiousnessWeights = infectiousnessWeights
        self.reportTypeWhenMissing = reportTypeWhenMissing
        
        self.v2RiskThreshold = v2RiskThreshold
        
        self.riskScoreCalculatorConfig = riskScoreCalculatorConfig
    }
}
