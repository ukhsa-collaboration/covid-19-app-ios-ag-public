//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import ExposureNotification
import RiskScore

@available(iOS 13.7, *)
struct ExposureWindowRiskManager: ExposureRiskManaging {
    
    var checkFrequency: TimeInterval {
        4 * 60 * 60 // 4 hours (6 times a day)
    }
    
    private let controller: ExposureNotificationDetectionController
    private let riskCalculator: ExposureWindowRiskCalculator
    
    init(
        controller: ExposureNotificationDetectionController,
        riskCalculator: ExposureWindowRiskCalculator
    ) {
        self.controller = controller
        self.riskCalculator = riskCalculator
    }
    
    var preferredProcessingMode: ProcessingMode {
        .bulk
    }
    
    func riskInfo(for summary: ENExposureDetectionSummary, configuration: ExposureDetectionConfiguration) -> AnyPublisher<ExposureRiskInfo?, Error> {
        return controller.getExposureWindows(summary: summary)
            .map { exposureWindows in
                self.riskCalculator.riskInfo(
                    for: exposureWindows,
                    configuration: configuration,
                    riskScoreCalculator: RiskScoreCalculator(configuration: configuration.riskScoreCalculatorConfig)
                )
            }.eraseToAnyPublisher()
    }
}
