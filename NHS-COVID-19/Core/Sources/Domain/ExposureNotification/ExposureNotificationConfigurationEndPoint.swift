//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct ExposureNotificationConfigurationEndPoint: HTTPEndpoint {
    
    func request(for input: Void) throws -> HTTPRequest {
        .get("/distribution/exposure-configuration")
    }
    
    func parse(_ response: HTTPResponse) throws -> ExposureDetectionConfiguration {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .appNetworking
        let configuration = try decoder.decode(Payload.self, from: response.body.content)
        return ExposureDetectionConfiguration(
            exposureNotification: configuration.exposureNotification,
            riskCalculation: configuration.riskCalculation
        )
    }
    
}

private struct Payload: Codable {
    
    struct ExposureNotification: Codable {
        var transmissionRiskWeight: Double
        var attenuationLevelValues: [Int]
        var minimumRiskScore: Double
        var attenuationDurationThresholds: [Int]
        var attenuationWeight: Double
        var daysSinceLastExposureLevelValues: [Int]
        var durationLevelValues: [Int]
        var durationWeight: Double
        var daysSinceLastExposureWeight: Double
        var transmissionRiskLevelValues: [Int]
    }
    
    struct RiskCalculation: Codable {
        var durationBucketWeights: [Double]
        var riskThreshold: Double
    }
    
    var exposureNotification: ExposureNotification
    var riskCalculation: RiskCalculation
}

private extension ExposureDetectionConfiguration {
    
    init(exposureNotification: Payload.ExposureNotification, riskCalculation: Payload.RiskCalculation) {
        self.init(
            transmitionWeight: exposureNotification.transmissionRiskWeight,
            durationWeight: exposureNotification.durationWeight,
            attenuationWeight: exposureNotification.attenuationWeight,
            daysWeight: exposureNotification.daysSinceLastExposureWeight,
            transmition: exposureNotification.transmissionRiskLevelValues,
            duration: exposureNotification.durationLevelValues,
            daysSinceLastExposure: exposureNotification.daysSinceLastExposureLevelValues,
            attenuation: exposureNotification.attenuationLevelValues,
            thresholds: exposureNotification.attenuationDurationThresholds,
            durationBucketWeights: riskCalculation.durationBucketWeights,
            riskThreshold: riskCalculation.riskThreshold
        )
    }
    
}
