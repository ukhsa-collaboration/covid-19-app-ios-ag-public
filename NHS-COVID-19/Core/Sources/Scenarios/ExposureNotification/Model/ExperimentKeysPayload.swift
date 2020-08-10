//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification
import Foundation

struct CollectedExperimentKeysPayload: Codable {
    var devices: [ExperimentKeysPayload]
}

struct CollectedExperimentResultsPayload: Codable {
    var devices: [ExperimentResultsPayload]
}

struct TemporaryTracingKey: Codable {
    var key: String
    var intervalNumber: Int
    var intervalCount: Int
    
    var exposureKey: ExposureKey {
        ExposureKey(
            keyData: Data(base64Encoded: key)!,
            rollingPeriod: ENIntervalNumber(intervalCount),
            rollingStartNumber: ENIntervalNumber(intervalNumber),
            transmissionRiskLevel: 7
        )
    }
}

struct ExperimentKeysPayload: Codable {
    
    typealias TemporaryTracingKey = Scenarios.TemporaryTracingKey
    
    struct Info: Codable {
        var deviceName: String
        var experimentName: String
    }
    
    var regions: [String]
    var temporaryTracingKeys: [TemporaryTracingKey]
    var info: Info
}

struct ExperimentResultsPayload: Codable {
    
    struct Summary: Codable {
        var attenuationDurations: [Double]
        var daysSinceLastExposure: Int
        var matchedKeyCount: Int
        var maximumRiskScore: Int
    }
    
    struct ExposureInfo: Codable {
        var attenuationDurations: [Double]
        var attenuationValue: Int
        var date: Date
        var duration: TimeInterval
        var totalRiskScore: Int
        var transmissionRiskLevel: Int
        var metadata: [String: String]?
    }
    
    typealias Info = ExperimentKeysPayload.Info
    
    var info: Info
    var summary: Summary
    var exposureInfos: [ExposureInfo]
}

extension ExperimentResultsPayload.Summary {
    init(summary: ENExposureDetectionSummary) {
        self.init(
            attenuationDurations: summary.attenuationDurations.map { $0.doubleValue },
            daysSinceLastExposure: summary.daysSinceLastExposure,
            matchedKeyCount: Int(summary.matchedKeyCount),
            maximumRiskScore: Int(summary.maximumRiskScore)
        )
    }
}

extension ExperimentResultsPayload.ExposureInfo {
    init(info: ENExposureInfo) {
        self.init(
            attenuationDurations: info.attenuationDurations.map { $0.doubleValue },
            attenuationValue: Int(info.attenuationValue),
            date: info.date,
            duration: info.duration,
            totalRiskScore: Int(info.totalRiskScore),
            transmissionRiskLevel: Int(info.transmissionRiskLevel),
            metadata: info.metadata.map {
                Dictionary(uniqueKeysWithValues: $0.map { ("\($0)", "\($1)") })
            }
        )
    }
}

extension ExperimentKeysPayload {
    
    init(keys: [ENTemporaryExposureKey], deviceManager: DeviceManager) {
        let mappedKeys = keys.map(ExperimentKeysPayload.TemporaryTracingKey.init)
        
        let info = ExperimentKeysPayload.Info(
            deviceName: deviceManager.deviceName,
            experimentName: deviceManager.experimentName
        )
        
        self.init(
            regions: ["UK"],
            temporaryTracingKeys: mappedKeys,
            info: info
        )
    }
    
}

extension TemporaryTracingKey {
    
    init(key: ENTemporaryExposureKey) {
        self.init(
            key: key.keyData.base64EncodedString(),
            intervalNumber: Int(key.rollingStartNumber),
            intervalCount: Int(key.rollingPeriod)
        )
    }
    
}
