//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import RiskScore

extension ExposureDetectionConfiguration {
    static let dummyForTesting = ExposureDetectionConfiguration(
        transmitionWeight: 0.0,
        durationWeight: 0.0,
        attenuationWeight: 0.0,
        daysWeight: 0.0,
        transmition: [],
        duration: [],
        daysSinceLastExposure: [],
        attenuation: [],
        thresholds: [],
        durationBucketWeights: [],
        riskThreshold: 0.0,
        daysSinceOnsetToInfectiousness: [],
        infectiousnessWeights: [],
        reportTypeWhenMissing: 0,
        v2RiskThreshold: 0.0,
        riskScoreCalculatorConfig: RiskScoreCalculatorConfiguration(
            sampleResolution: 1.0,
            expectedDistance: 1.0,
            minimumDistance: 1.0,
            rssiParameters: RssiParameters(weightCoefficient: 1.0, intercept: 1.0, covariance: 1.0),
            powerLossParameters: PowerLossParameters(wavelength: 1.0, pathLossFactor: 1.0, refDeviceLoss: 1.0),
            observationType: .gen,
            initialData: InitialData(mean: 1.0, covariance: 1.0),
            smootherParameters: SmootherParameters(alpha: 1.0, beta: 1.0, kappa: 1.0)
        )
    )
}

