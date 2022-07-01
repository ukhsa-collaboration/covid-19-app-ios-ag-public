//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct ExposureConfigurationHandler: RequestHandler {
    var paths = ["/distribution/exposure-configuration"]

    var response: Result<HTTPResponse, HTTPRequestError> {
        Result.success(.ok(with: .json(exposureConfiguration)))
    }
}

private let exposureConfiguration = """
{
"exposureNotification": {
"minimumRiskScore": 11,
"attenuationDurationThresholds": [55, 63],
"attenuationLevelValues": [0, 1, 1, 1, 1, 1, 1, 1],
"daysSinceLastExposureLevelValues": [5, 5, 5, 5, 5, 5, 5, 5],
"durationLevelValues": [0, 0, 0, 1, 1, 1, 1, 1],
"transmissionRiskLevelValues": [1, 2, 3, 4, 5, 6, 7, 8],
"attenuationWeight": 50.0,
"daysSinceLastExposureWeight": 20,
"durationWeight": 50.0,
"transmissionRiskWeight": 50.0
},
"riskCalculation": {
"durationBucketWeights": [1.0, 0.5, 0.0],
"riskThreshold": 20.0
},
"riskScore": {
"sampleResolution": 1.0,
"expectedDistance": 0.1,
"minimumDistance": 1.0,
"rssiParameters" : {
"weightCoefficient": 0.1270547531082051,
"intercept": 4.2309333657856945,
"covariance": 0.4947614361027773
},
"powerLossParameters": {
"wavelength": 0.125,
"pathLossFactor": 20.0,
"refDeviceLoss": 0.0
},
"observationType": "log",
"initialData": {
"mean": 2.0,
"covariance": 10.0
},
"smootherParameters": {
"alpha": 1.0,
"beta": 0.0,
"kappa": 0.0
}
},
  "v2RiskCalculation": {
    "daysSinceOnsetToInfectiousness":[0,0,0,0,0,0,0,0,0,1,1,1,2,2,2,2,2,2,1,1,1,1,1,1,0,0,0,0,0],
    "infectiousnessWeights": [0.0, 0.4, 1.0],
    "reportTypeWhenMissing": 1,
    "riskThreshold": 120
  }
}
"""
