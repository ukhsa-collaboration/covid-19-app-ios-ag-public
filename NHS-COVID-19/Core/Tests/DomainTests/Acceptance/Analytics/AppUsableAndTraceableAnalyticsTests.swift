//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class AppUsableAndTraceableAnalyticsTests: AnalyticsTests {

    func testActiveENDoesTriggerUsableAndContactTraceableFields() throws {
        // Onboarding on day 1, no change
        assertOnFields { assertFields in
            assertFields.isPresent(\.appIsUsableBackgroundTick)
            assertFields.isNotPresent(\.appIsUsableBluetoothOffBackgroundTick)
            assertFields.isPresent(\.appIsContactTraceableBackgroundTick)
        }
    }

    func testRestrictedDoesMakeAppUnusableAndUntraceable() throws {

        // Onboarding on day 1, everything fine
        assertAnalyticsPacketIsNormal()

        // Change state to one that does not allow exposure detection
        $instance.exposureNotificationManager.exposureNotificationStatus = .restricted

        // On day 2, the backgroundtasks should've run but we did not increase the two fields
        assertOnFields { assertFields in
            assertFields.isNotPresent(\.appIsUsableBackgroundTick)
            assertFields.isNotPresent(\.appIsUsableBluetoothOffBackgroundTick)
            assertFields.isNotPresent(\.appIsContactTraceableBackgroundTick)
        }
    }

    func testBluetoothOffDoesMakeAppUnusableAndUntraceable() throws {

        // Onboarding on day 1, everything fine
        assertAnalyticsPacketIsNormal()

        // Change state to one that does not allow exposure detection
        $instance.exposureNotificationManager.exposureNotificationStatus = .bluetoothOff

        // On day 2, the backgroundtasks should've run but we did not increase the two fields
        assertOnFields { assertFields in
            assertFields.isPresent(\.appIsUsableBackgroundTick)
            assertFields.isPresent(\.appIsUsableBluetoothOffBackgroundTick)
        }
    }

    func testDisabledDoesMakeAppUntraceableButNotUnusable() throws {

        // Onboarding on day 1, everything fine
        assertAnalyticsPacketIsNormal()

        // Change state to one that does not allow exposure detection
        $instance.exposureNotificationManager.exposureNotificationStatus = .disabled
        $instance.exposureNotificationManager.exposureNotificationEnabled = false

        // On day 2, the backgroundtasks should've run - the app shoul've been usable, but not contact traceable
        assertOnFields { assertFields in
            assertFields.isPresent(\.appIsUsableBackgroundTick)
            assertFields.isNotPresent(\.appIsUsableBluetoothOffBackgroundTick)
            assertFields.isNotPresent(\.appIsContactTraceableBackgroundTick)
            assertFields.isPresent(\.encounterDetectionPausedBackgroundTick)
        }
    }

}
