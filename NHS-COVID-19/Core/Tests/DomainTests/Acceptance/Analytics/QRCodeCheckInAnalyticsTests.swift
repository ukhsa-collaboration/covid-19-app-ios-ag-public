//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class QRCodeCheckInAnalyticsTests: AnalyticsTests {
    private var checkInFunctionality: QRCodeCheckIn!
    
    override func setUpFunctionalities() {
        checkInFunctionality = QRCodeCheckIn(context: try! context())
    }
    
    func testCountsNumberOfCheckIns() throws {
        try checkInFunctionality.checkIn(date: currentDateProvider.currentDate)
        
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.checkedIn)
        }
    }
    
    func testCountsNumberOfCancelledCheckIns() throws {
        try checkInFunctionality.checkInAndCancel(date: currentDateProvider.currentDate)
        
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.checkedIn)
            assertField.equals(expected: 1, \.canceledCheckIn)
        }
    }
}
