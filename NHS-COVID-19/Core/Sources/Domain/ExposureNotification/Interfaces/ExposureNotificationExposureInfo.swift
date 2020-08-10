//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification

public protocol ExposureNotificationExposureInfo {
    var attenuationDurations: [NSNumber] { get }
    var date: Date { get }
    var totalRiskScore: ENRiskScore { get }
}

extension ENExposureInfo: ExposureNotificationExposureInfo {}
