//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Interface
import TestSupport
import XCTest
@testable import Domain
@testable import Integration

final class IsolationStateAdapterTests: XCTestCase {
    
    func testNotIsolating() {
        let state = Interface.IsolationState(domainState: .noNeedToIsolate, today: .today)
        
        TS.assert(state, equals: .notIsolating)
    }
    
    func testIsolating() {
        let timeZone = TimeZone.current
        let today = LocalDay(gregorianDay: GregorianDay(year: 2020, month: 3, day: 13), timeZone: timeZone)
        let tomorrow = LocalDay(gregorianDay: GregorianDay(year: 2020, month: 3, day: 14), timeZone: timeZone)
        
        let isolation = Isolation(fromDay: today, untilStartOfDay: tomorrow, reason: .contactCase(.exposureDetection))
        let state = Interface.IsolationState(
            domainState: .isolate(isolation),
            today: today
        )
        
        guard case .isolating(days: 1, percentRemaining: _, endDate: tomorrow.startOfDay) = state else {
            XCTFail()
            return
        }
    }
    
}
