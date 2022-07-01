//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import ExposureNotification

@available(iOS 13.7, *)
class StubExposureWindow: ENExposureWindow {
    override var scanInstances: [ENScanInstance] {
        [
            StubScanInstance(),
            StubScanInstance(),
            StubScanInstance(),
            StubScanInstance(),
            StubScanInstance(),
            StubScanInstance(),
        ]
    }

    override var date: Date {
        self.exposureDate
    }

    override var infectiousness: ENInfectiousness {
        .high
    }

    let exposureDate: Date

    init(exposureDate: Date) {
        self.exposureDate = exposureDate
    }

    class StubScanInstance: ENScanInstance {
        override var minimumAttenuation: ENAttenuation {
            30
        }

        override var typicalAttenuation: ENAttenuation {
            30
        }

        override var secondsSinceLastScan: Int {
            120
        }
    }
}
