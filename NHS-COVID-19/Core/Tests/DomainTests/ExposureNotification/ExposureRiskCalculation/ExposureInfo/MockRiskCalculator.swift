//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import ExposureNotification
@testable import Domain

struct MockRiskCalculator: ExposureRiskCalculating {

    func riskInfo(for exposureInfo: [ExposureNotificationExposureInfo], configuration: ExposureDetectionConfiguration) -> ExposureRiskInfo? {
        exposureInfo.map {
            ExposureRiskInfo(riskScore: Double($0.totalRiskScore), riskScoreVersion: 1, day: .today, isConsideredRisky: Double($0.totalRiskScore) > configuration.riskThreshold)
        }.max { $0.riskScore < $1.riskScore }
    }
}
