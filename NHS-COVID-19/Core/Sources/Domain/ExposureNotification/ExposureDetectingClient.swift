//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import Foundation

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
        riskThreshold: Double
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
    }
}

protocol ExposureDetectingClient {
    func post(token: DiagnosisKeySubmissionToken, diagnosisKeys: [ENTemporaryExposureKey]) -> AnyPublisher<Void, NetworkRequestError>
    func getExposureKeys(for increment: Increment) -> AnyPublisher<ZIPManager, NetworkRequestError>
    func getConfiguration() -> AnyPublisher<ExposureDetectionConfiguration, NetworkRequestError>
}
