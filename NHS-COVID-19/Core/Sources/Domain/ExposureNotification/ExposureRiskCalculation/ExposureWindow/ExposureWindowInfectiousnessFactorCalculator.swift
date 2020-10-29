//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification
import Foundation

@available(iOS 13.7, *)
class ExposureWindowInfectiousnessFactorCalculator {
    func infectiousnessFactor(for infectiousness: ENInfectiousness, config: ExposureDetectionConfiguration) -> Double {
        return config.infectiousnessWeights[Int(infectiousness.rawValue)]
    }
}
