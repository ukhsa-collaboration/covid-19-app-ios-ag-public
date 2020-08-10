//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import XCTest
@testable import Domain

class RiskInfoTests: XCTestCase {
    
    func testNewerDayHasHigherPriorityEvenOlderRiskIsHigher() {
        let older = RiskInfo(riskScore: 200, day: GregorianDay(year: 2020, month: 4, day: 17))
        let newer = RiskInfo(riskScore: 100, day: GregorianDay(year: 2020, month: 4, day: 18))
        XCTAssert(newer.isHigherPriority(than: older))
    }
    
    func testOnEqualDayDayHigherRiskHasHigherPriority() {
        let lowerRisk = RiskInfo(riskScore: 100, day: GregorianDay(year: 2020, month: 4, day: 17))
        let higherRisk = RiskInfo(riskScore: 200, day: GregorianDay(year: 2020, month: 4, day: 17))
        XCTAssert(higherRisk.isHigherPriority(than: lowerRisk))
    }
    
}
