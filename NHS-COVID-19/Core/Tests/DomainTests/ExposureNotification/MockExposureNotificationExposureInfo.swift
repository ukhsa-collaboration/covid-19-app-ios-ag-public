//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification
import Foundation
@testable import Domain

struct MockENExposureInfo: ExposureNotificationExposureInfo {
    var attenuationDurations: [NSNumber]
    var date: Date
    var totalRiskScore: ENRiskScore
}
