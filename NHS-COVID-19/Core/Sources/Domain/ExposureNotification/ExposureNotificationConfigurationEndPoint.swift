//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import RiskScore

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
            riskCalculation: configuration.riskCalculation,
            v2RiskCalculation: configuration.v2RiskCalculation,
            riskScore: configuration.riskScore
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

    struct V2RiskCalculation: Codable {
        var daysSinceOnsetToInfectiousness: [Int]
        var infectiousnessWeights: [Double]
        var reportTypeWhenMissing: Int
        var riskThreshold: Double
    }

    var exposureNotification: ExposureNotification
    var riskCalculation: RiskCalculation
    var v2RiskCalculation: V2RiskCalculation
    var riskScore: RiskScore
}

struct RiskScore: Codable {
    var sampleResolution: Double
    var expectedDistance: Double
    var minimumDistance: Double

    var rssiParameters: RssiParameters
    var powerLossParameters: PowerLossParameters
    var observationType: ObservationType
    var initialData: InitialData
    var smootherParameters: SmootherParameters

    struct RssiParameters: Codable {
        var weightCoefficient: Double
        var intercept: Double
        var covariance: Double
    }

    struct PowerLossParameters: Codable {
        var wavelength: Double
        var pathLossFactor: Double
        var refDeviceLoss: Double
    }

    enum ObservationType: String, Codable {
        case log
        case gen
    }

    struct InitialData: Codable {
        var mean: Double
        var covariance: Double
    }

    struct SmootherParameters: Codable {
        var alpha: Double
        var beta: Double
        var kappa: Double
    }
}

private extension RiskScoreCalculatorConfiguration {
    init(riskScore: RiskScore) {
        self.init(
            sampleResolution: riskScore.sampleResolution,
            expectedDistance: riskScore.expectedDistance,
            minimumDistance: riskScore.minimumDistance,
            rssiParameters: RssiParameters(
                weightCoefficient: riskScore.rssiParameters.weightCoefficient,
                intercept: riskScore.rssiParameters.intercept,
                covariance: riskScore.rssiParameters.covariance
            ),
            powerLossParameters: PowerLossParameters(
                wavelength: riskScore.powerLossParameters.wavelength,
                pathLossFactor: riskScore.powerLossParameters.pathLossFactor,
                refDeviceLoss: riskScore.powerLossParameters.refDeviceLoss
            ),
            observationType: riskScore.observationType.rawValue == "log" ? .log : .gen,
            initialData: InitialData(
                mean: riskScore.initialData.mean,
                covariance: riskScore.initialData.covariance
            ),
            smootherParameters: SmootherParameters(
                alpha: riskScore.smootherParameters.alpha,
                beta: riskScore.smootherParameters.beta,
                kappa: riskScore.smootherParameters.kappa
            )
        )
    }
}

private extension ExposureDetectionConfiguration {

    init(exposureNotification: Payload.ExposureNotification, riskCalculation: Payload.RiskCalculation, v2RiskCalculation: Payload.V2RiskCalculation, riskScore: RiskScore) {
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
            riskThreshold: riskCalculation.riskThreshold,
            daysSinceOnsetToInfectiousness: v2RiskCalculation.daysSinceOnsetToInfectiousness,
            infectiousnessWeights: v2RiskCalculation.infectiousnessWeights,
            reportTypeWhenMissing: v2RiskCalculation.reportTypeWhenMissing,
            v2RiskThreshold: v2RiskCalculation.riskThreshold,
            riskScoreCalculatorConfig: RiskScoreCalculatorConfiguration(riskScore: riskScore)
        )
    }

}
