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
}

@available(iOS 13.7, *)
extension ENScanInstance: ExposureNotificationScanInstance {}

@available(iOS 13.7, *)
extension ExposureNotificationScanInstance {
    func toScanInstance() -> ScanInstance {
        ScanInstance(attenuationValue: minimumAttenuation, secondsSinceLastScan: secondsSinceLastScan)
    }
}
