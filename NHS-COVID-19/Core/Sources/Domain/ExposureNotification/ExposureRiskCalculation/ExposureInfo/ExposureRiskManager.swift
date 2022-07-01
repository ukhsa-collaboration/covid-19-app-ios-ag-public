//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import ExposureNotification
import Foundation

struct ExposureRiskManager: ExposureRiskManaging {

    var checkFrequency: TimeInterval {
        2 * 60 * 60 // 2 hours
    }

    let riskCalculator: ExposureRiskCalculating
    let controller: ExposureNotificationDetectionController

    init(
        riskCalculator: ExposureRiskCalculating = ExposureRiskCalculator(),
        controller: ExposureNotificationDetectionController
    ) {
        self.riskCalculator = riskCalculator
        self.controller = controller
    }

    var preferredProcessingMode: ProcessingMode {
        .incremental
    }

    func riskInfo(for summary: ENExposureDetectionSummary, configuration: ExposureDetectionConfiguration) -> AnyPublisher<ExposureRiskInfo?, Error> {
        controller.getExposureInfo(
            summary: summary
        )
        .map { exposureInfo in
            riskCalculator.riskInfo(for: exposureInfo, configuration: configuration)
        }.eraseToAnyPublisher()
    }
}
