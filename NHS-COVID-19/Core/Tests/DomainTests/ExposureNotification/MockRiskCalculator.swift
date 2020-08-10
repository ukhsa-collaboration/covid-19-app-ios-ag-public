//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import ExposureNotification
@testable import Domain

class MockRiskCalculator: ExposureRiskCalculating {
    init(configuration: ExposureDetectionConfiguration) {}
    
    func riskInfo(for exposureInfo: [ExposureNotificationExposureInfo]) -> RiskInfo? {
        exposureInfo.map {
            RiskInfo(riskScore: Double($0.totalRiskScore), day: .today)
        }.max { $0.riskScore < $1.riskScore }
    }
    
    func createExposureNotificationConfiguration() -> ENExposureConfiguration {
        ENExposureConfiguration()
    }
}
