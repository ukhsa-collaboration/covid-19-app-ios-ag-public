//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class ExposureNotificationNotRunningAnalyticsTests: AnalyticsTests {
    
    func testRestrictedDoesSendAnalyticsPackage() throws {
        
        // Onboarding on day 1, everything fine
        assertAnalyticsPacketIsNormal()
        
        let lastendDate = lastMetricsPayload?.analyticsWindow.endDate
        
        // Change state to one that does not allow exposure detection
        $instance.exposureNotificationManager.exposureNotificationStatus = .restricted
        
        // On day 2, the backgroundtasks should've run but we did not increase .runningNormallyBackgroundTick
        assertOnFields { assertFields in
            assertFields.isLessThanTotalBackgroundTasks(\.runningNormallyBackgroundTick)
            assertFields.isLessThanTotalBackgroundTasks(\.appIsUsableBackgroundTick)
            assertFields.isLessThanTotalBackgroundTasks(\.appIsUsableBluetoothOffBackgroundTick)
        }
        
        // Check again that a new window was sent
        XCTAssert(lastendDate != lastMetricsPayload?.analyticsWindow.endDate)
    }
    
    func testBluetoothOffDoesSendAnalyticsPackage() throws {
        
        // Onboarding on day 1, everything fine
        assertAnalyticsPacketIsNormal()
        
        let lastendDate = lastMetricsPayload?.analyticsWindow.endDate
        
        // Change state to one that does not allow exposure detection
        $instance.exposureNotificationManager.exposureNotificationStatus = .bluetoothOff
        
        // On day 2, the backgroundtasks should've run but we did not increase .runningNormallyBackgroundTick
        assertOnFields { assertFields in
            assertFields.isLessThanTotalBackgroundTasks(\.runningNormallyBackgroundTick)
            assertFields.isPresent(\.appIsUsableBackgroundTick)
            assertFields.isPresent(\.appIsUsableBluetoothOffBackgroundTick)
        }
        
        // Check again that a new window was sent
        XCTAssert(lastendDate != lastMetricsPayload?.analyticsWindow.endDate)
    }
}
