//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import ExposureNotification
@testable import Domain

class MockRiskCalculator: ExposureRiskCalculating {
    let configuration: ExposureDetectionConfiguration
    init(configuration: ExposureDetectionConfiguration) {
        self.configuration = configuration
    }
    
    func riskInfo(for exposureInfo: [ExposureNotificationExposureInfo]) -> ExposureRiskInfo? {
        exposureInfo.map {
            ExposureRiskInfo(riskScore: Double($0.totalRiskScore), day: .today, isConsideredRisky: Double($0.totalRiskScore) > self.configuration.riskThreshold)
        }.max { $0.riskScore < $1.riskScore }
    }
    
    func createExposureNotificationConfiguration() -> ENExposureConfiguration {
        ENExposureConfiguration()
    }
}
