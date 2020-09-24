//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification
import Foundation

struct Experiment: Codable {
    
    typealias Key = Scenarios.TemporaryTracingKey
    
    enum Role: String {
        case lead
        case participant
    }
    
    struct Participant: Codable, Identifiable {
        var deviceName: String
        var temporaryTracingKeys: [Key]
        var results: [DetectionResults]?
        
        var id: String {
            deviceName
        }
    }
    
    struct Create: Codable {
        var experimentCreatedAt = Date()
        var experimentName: String
        var automaticDetectionFrequency: TimeInterval?
        var requestedConfigurations: [RequestedConfiguration]
        var lead: Participant
    }
    
    typealias Summary = ExperimentResultsPayload.Summary
    typealias ExposureInfo = ExperimentResultsPayload.ExposureInfo
    
    struct DetectionResult: Codable {
        var deviceName: String
        var summary: Summary
        var exposureInfos: [ExposureInfo]
    }
    
    struct DetectionResults: Codable {
        var timestamp: Date
        var configuration: DetectionConfiguration
        var counterparts: [DetectionResult]
    }
    
    struct DetectionConfiguration: Codable {
        var minimumRiskScore: Int
        var minimumRiskScoreFullRange: Double?
        var attenuationDurationThresholds: [Int]
        var attenuationLevelValues: [Int]
        var attenuationWeight: Double
        var daysSinceLastExposureLevelValues: [Int]
        var daysSinceLastExposureWeight: Double
        var durationLevelValues: [Int]
        var durationWeight: Double
        var transmissionRiskLevelValues: [Int]
        var transmissionRiskWeight: Double
    }
    
    struct RequestedConfiguration: Codable {
        var attenuationDurationThresholds: [Int]
    }
    
    var experimentName: String
    var experimentId: String
    var lead: Participant
    var automaticDetectionFrequency: TimeInterval?
    var requestedConfigurations: [RequestedConfiguration]
    var participants: [Participant]
    
}

extension Experiment.DetectionConfiguration {
    
    init(_ configuration: ENExposureConfiguration) {
        minimumRiskScore = Int(configuration.minimumRiskScore)
        minimumRiskScoreFullRange = configuration.minimumRiskScoreFullRange
        attenuationDurationThresholds = configuration.attenuationDurationThresholds.map { $0.intValue }
        attenuationLevelValues = configuration.attenuationLevelValues.map { $0.intValue }
        attenuationWeight = configuration.attenuationWeight
        daysSinceLastExposureLevelValues = configuration.daysSinceLastExposureLevelValues.map { $0.intValue }
        daysSinceLastExposureWeight = configuration.daysSinceLastExposureWeight
        durationLevelValues = configuration.durationLevelValues.map { $0.intValue }
        durationWeight = configuration.durationWeight
        transmissionRiskLevelValues = configuration.transmissionRiskLevelValues.map { $0.intValue }
        transmissionRiskWeight = configuration.transmissionRiskWeight
    }
    
}

extension Experiment.RequestedConfiguration {
    
    init(_ configuration: ENExposureConfiguration) {
        attenuationDurationThresholds = configuration.attenuationDurationThresholds.map { $0.intValue }
    }
    
}
