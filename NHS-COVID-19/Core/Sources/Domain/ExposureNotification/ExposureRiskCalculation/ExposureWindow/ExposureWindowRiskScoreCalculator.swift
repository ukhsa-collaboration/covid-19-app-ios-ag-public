//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import RiskScore

protocol ExposureWindowRiskScoreCalculator {
    func calculate(instances: [ScanInstance]) -> Double
}

@available(iOS 13.7, *)
extension RiskScoreCalculator: ExposureWindowRiskScoreCalculator {}
