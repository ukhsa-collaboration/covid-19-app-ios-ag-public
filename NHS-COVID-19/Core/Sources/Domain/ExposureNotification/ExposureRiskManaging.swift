//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import ExposureNotification
import Foundation

enum ExposureRiskManagingProcessingMode {
    case incremental
    case bulk
}

protocol ExposureRiskManaging {
    typealias ProcessingMode = ExposureRiskManagingProcessingMode
    
    var preferredProcessingMode: ProcessingMode { get }
    var checkFrequency: TimeInterval { get }
    
    func riskInfo(for summary: ENExposureDetectionSummary, configuration: ExposureDetectionConfiguration) -> AnyPublisher<ExposureRiskInfo?, Error>
}
