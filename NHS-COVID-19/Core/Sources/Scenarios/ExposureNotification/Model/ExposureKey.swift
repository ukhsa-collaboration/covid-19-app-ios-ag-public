//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification
import Foundation

struct ExposureKey: Codable {
    var keyData: Data
    var rollingPeriod: ENIntervalNumber
    var rollingStartNumber: ENIntervalNumber
    var transmissionRiskLevel: ENRiskLevel
}
