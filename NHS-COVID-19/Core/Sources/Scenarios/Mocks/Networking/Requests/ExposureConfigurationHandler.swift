//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct ExposureConfigurationHandler: RequestHandler {
    var paths = ["/submission/diagnosis-keys"]
    
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
}
}
"""
