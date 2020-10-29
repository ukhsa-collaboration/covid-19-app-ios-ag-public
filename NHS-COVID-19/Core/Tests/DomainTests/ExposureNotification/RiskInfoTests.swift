//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import XCTest
@testable import Domain

class RiskInfoTests: XCTestCase {
    
    func testNewerDayHasHigherPriorityEvenOlderRiskIsHigher() {
        let older = RiskInfo(riskScore: 200, riskScoreVersion: 1, day: GregorianDay(year: 2020, month: 4, day: 17))
        let newer = RiskInfo(riskScore: 100, riskScoreVersion: 1, day: GregorianDay(year: 2020, month: 4, day: 18))
        XCTAssert(newer.isHigherPriority(than: older))
    }
    
    func testOnEqualDayDayHigherRiskHasHigherPriority() {
        let lowerRisk = RiskInfo(riskScore: 100, riskScoreVersion: 1, day: GregorianDay(year: 2020, month: 4, day: 17))
        let higherRisk = RiskInfo(riskScore: 200, riskScoreVersion: 1, day: GregorianDay(year: 2020, month: 4, day: 17))
        XCTAssert(higherRisk.isHigherPriority(than: lowerRisk))
    }
    
    func testDontWorryNotificationWithV1() {
        let risk = ExposureRiskInfo(riskScore: 100, riskScoreVersion: 1, day: GregorianDay(year: 2020, month: 4, day: 17), isConsideredRisky: true)
        XCTAssertTrue(risk.shouldShowDontWorryNotification)
    }
    
    func testNoDontWorryNotificationWithV2() {
        let risk = ExposureRiskInfo(riskScore: 100, riskScoreVersion: 2, day: GregorianDay(year: 2020, month: 4, day: 17), isConsideredRisky: true)
        XCTAssertFalse(risk.shouldShowDontWorryNotification)
    }
}
