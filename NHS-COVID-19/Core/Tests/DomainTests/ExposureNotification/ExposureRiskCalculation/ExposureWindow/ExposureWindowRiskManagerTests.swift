//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import Foundation
import Scenarios
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class ExposureWindowRiskManagerTests: XCTestCase {
    private var manager: ExposureWindowRiskManager!
    private var controller: MockController!
    private var riskCalculator: MockExposureWindowRiskCalculator!
    
    private let summary = ENExposureDetectionSummary()
    private var configuration: ExposureDetectionConfiguration!
    
    override func setUp() {
        configuration = .dummyForTesting
        controller = MockController()
        riskCalculator = MockExposureWindowRiskCalculator(dateProvider: { Date() }, isolationLength: DayDuration(10), submitExposureWindows: { _ in })
        manager = ExposureWindowRiskManager(controller: controller, riskCalculator: riskCalculator)
    }
    
    func testRequestsExposureWindows() {
        _ = manager.riskInfo(for: summary, configuration: configuration)
        
        XCTAssert(controller.exposureWindowsWasCalled)
    }
    
    func testCallsRiskCalculatorWithExposureWindowsAndReturnsExposureRiskInfo() {
        let expectedExposureWindows = [ENExposureWindow()]
        let expectedExposureRiskInfo = ExposureRiskInfo(riskScore: 7.0, riskScoreVersion: 1, day: GregorianDay.today, isConsideredRisky: false)
        controller.exposureWindows = expectedExposureWindows
        riskCalculator.exposureRiskInfo = expectedExposureRiskInfo
        
        let exposureRiskInfo = try! manager.riskInfo(for: summary, configuration: configuration).await().get()
        
        XCTAssert(riskCalculator.riskInfoCalled)
        XCTAssertEqual(exposureRiskInfo, expectedExposureRiskInfo)
    }
}

extension ExposureRiskInfo: Equatable {
    public static func == (lhs: ExposureRiskInfo, rhs: ExposureRiskInfo) -> Bool {
        return lhs.isConsideredRisky == rhs.isConsideredRisky
            && lhs.day == rhs.day
            && lhs.riskScore == rhs.riskScore
    }
}

@available(iOS 13.7, *)
private class MockController: ExposureNotificationDetectionController {
    var exposureWindowsWasCalled: Bool = false
    
    var exposureWindows: [ENExposureWindow] = []
    
    convenience init() {
        self.init(manager: MockExposureNotificationManager())
    }
    
    @available(iOS 13.7, *)
    override func getExposureWindows(summary: ENExposureDetectionSummary) -> AnyPublisher<[ENExposureWindow], Error> {
        exposureWindowsWasCalled = true
        return Result.success(exposureWindows).publisher.eraseToAnyPublisher()
    }
}

@available(iOS 13.7, *)
private class MockExposureWindowRiskCalculator: ExposureWindowRiskCalculator {
    var riskInfoCalled: Bool = false
    
    var exposureRiskInfo: ExposureRiskInfo?
    
    override func riskInfo(for exposureWindows: [ExposureNotificationExposureWindow], configuration: ExposureDetectionConfiguration, riskScoreCalculator: ExposureWindowRiskScoreCalculator) -> ExposureRiskInfo? {
        riskInfoCalled = true
        return exposureRiskInfo
    }
}
