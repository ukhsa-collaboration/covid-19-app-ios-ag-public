//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import TestSupport
import XCTest
@testable import Domain

class IsolationStateTests: XCTestCase {
    
    func testInitializingNotIsolating() {
        let state = IsolationState(logicalState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil))
        
        TS.assert(state, equals: .noNeedToIsolate())
    }
    
    func testInitializingNotIsolatingWhenNotAcknowledged() {
        let state = IsolationState(logicalState: .isolationFinishedButNotAcknowledged(Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(exposureDay: .today)))))
        
        TS.assert(state, equals: .noNeedToIsolate())
    }
    
    func testInitializingIsolating() {
        let timeZone = TimeZone(secondsFromGMT: .random(in: 100 ... 1000))!
        let day = LocalDay(year: 2020, month: 3, day: 17, timeZone: timeZone)
        let isolation = Isolation(fromDay: .today, untilStartOfDay: day, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))
        let state = IsolationState(logicalState: .isolating(isolation, endAcknowledged: false, startOfContactIsolationAcknowledged: true))
        
        TS.assert(state, equals: .isolate(isolation))
    }
    
}
