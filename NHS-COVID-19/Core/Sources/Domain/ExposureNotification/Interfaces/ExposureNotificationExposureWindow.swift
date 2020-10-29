//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification
import Foundation

@available(iOS 13.7, *)
protocol ExposureNotificationExposureWindow {
    var enScanInstances: [ExposureNotificationScanInstance] { get }
    var date: Date { get }
    var infectiousness: ENInfectiousness { get }
}

@available(iOS 13.7, *)
extension ENExposureWindow: ExposureNotificationExposureWindow {
    var enScanInstances: [ExposureNotificationScanInstance] {
        return scanInstances
    }
}
