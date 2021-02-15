//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification
import Foundation
import RiskScore

@available(iOS 13.7, *)
protocol ExposureNotificationScanInstance {
    var minimumAttenuation: ENAttenuation { get }
    var secondsSinceLastScan: Int { get }
    var typicalAttenuation: ENAttenuation { get }
}

@available(iOS 13.7, *)
extension ENScanInstance: ExposureNotificationScanInstance {}

@available(iOS 13.7, *)
extension ScanInstance {
    init(from enScanInstance: ExposureNotificationScanInstance) {
        self.init(attenuationValue: enScanInstance.minimumAttenuation, secondsSinceLastScan: enScanInstance.secondsSinceLastScan)
    }
}
