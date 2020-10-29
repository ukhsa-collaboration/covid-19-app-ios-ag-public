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

class ExposureRiskManagerTests: XCTestCase {
    
    private let mockSummary = ENExposureDetectionSummary()
    private let mockController = MockExposureNotificationDetectionController(manager: MockExposureNotificationManager())
    
    func testRequestsExposureInfo() {
        let exposureRiskManager = ExposureRiskManager(controller: mockController)
        
        _ = exposureRiskManager.riskInfo(for: mockSummary, configuration: .dummyForTesting)
        
        XCTAssert(mockController.exposureInfoRequested)
    }
    
    func testRiskCalculatorIsUsed() throws {
        let expectedRiskScore = 900.0
        let riskCalculator = StubRiskCalculator(expectedRiskScore: expectedRiskScore)
        let exposureRiskManager = ExposureRiskManager(riskCalculator: riskCalculator, controller: mockController)
        
        let riskInfoResult = try exposureRiskManager.riskInfo(for: mockSummary, configuration: .dummyForTesting).await()
        guard case let .success(riskInfo) = riskInfoResult else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(riskInfo?.riskScore, expectedRiskScore)
        XCTAssert(riskCalculator.riskInfoCalled)
    }
}

class MockExposureNotificationDetectionController: ExposureNotificationDetectionController {
    var exposureInfoRequested = false
    
    override func getExposureInfo(summary: ENExposureDetectionSummary) -> AnyPublisher<[ENExposureInfo], Error> {
        exposureInfoRequested = true
        
        return Future { promise in
            promise(.success([]))
        }.eraseToAnyPublisher()
    }
}

private class StubRiskCalculator: ExposureRiskCalculating {
    var riskInfoCalled = false
    let expectedRiskScore: Double
    
    init(expectedRiskScore: Double) {
        self.expectedRiskScore = expectedRiskScore
    }
    
    func riskInfo(for exposureInfo: [ExposureNotificationExposureInfo], configuration: ExposureDetectionConfiguration) -> ExposureRiskInfo? {
        riskInfoCalled = true
        return ExposureRiskInfo(riskScore: expectedRiskScore, riskScoreVersion: 1, day: GregorianDay.today, isConsideredRisky: expectedRiskScore > configuration.riskThreshold)
    }
}
