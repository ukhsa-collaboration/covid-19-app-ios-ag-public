//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Logging

extension ExposureDetectionStore {
    
    private static let logger = Logger(label: "ExposureNotification")
    
    func saveIfNeeded(exposureRiskInfo: ExposureRiskInfo) -> Bool {
        Self.logger.info("calculated risk info", metadata: .describing(exposureRiskInfo))
        if exposureRiskInfo.isConsideredRisky {
            Self.logger.info("risk score is significant. Saving it.")
            let riskInfo = RiskInfo(
                riskScore: exposureRiskInfo.riskScore,
                riskScoreVersion: exposureRiskInfo.riskScoreVersion,
                day: exposureRiskInfo.day
            )
            save(riskInfo: riskInfo)
            return true
        }
        return false
    }
    
}
