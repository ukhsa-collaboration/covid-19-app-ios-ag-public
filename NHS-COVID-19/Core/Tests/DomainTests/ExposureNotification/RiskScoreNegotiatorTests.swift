//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine

import XCTest
@testable import Domain

class RiskScoreNegotiatorTests: XCTestCase {
    
    func testRiskScoreIsSavedWhenNotIsolatingAndConsidererdRisky() {
        var riskInfo: RiskInfo?
        
        let negotiator = RiskScoreNegotiator(
            saveRiskScore: { riskInfo = $0 },
            getIsolationState: { .noNeedToIsolate },
            isolationState: Empty().eraseToAnyPublisher(),
            deleteRiskScore: {}
        )
        
        let result = negotiator.saveIfNeeded(exposureRiskInfo: ExposureRiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .today, isConsideredRisky: true))
        
        XCTAssertTrue(result)
        XCTAssertEqual(riskInfo, RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .today))
    }
    
    func testRiskScoreIsNotSavedWhenIsolating() {
        var riskInfo: RiskInfo?
        
        let negotiator = RiskScoreNegotiator(
            saveRiskScore: { riskInfo = $0 },
            getIsolationState: { .isolate(Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false))) },
            isolationState: Empty().eraseToAnyPublisher(),
            deleteRiskScore: {}
        )
        
        let result = negotiator.saveIfNeeded(exposureRiskInfo: ExposureRiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .today, isConsideredRisky: true))
        
        XCTAssertFalse(result)
        XCTAssertNil(riskInfo)
    }
    
    func testRiskScoreIsNotSavedWhenNotConsideredRisky() {
        var riskInfo: RiskInfo?
        
        let negotiator = RiskScoreNegotiator(
            saveRiskScore: { riskInfo = $0 },
            getIsolationState: { .noNeedToIsolate },
            isolationState: Empty().eraseToAnyPublisher(),
            deleteRiskScore: {}
        )
        
        let result = negotiator.saveIfNeeded(exposureRiskInfo: ExposureRiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .today, isConsideredRisky: false))
        
        XCTAssertFalse(result)
        XCTAssertNil(riskInfo)
    }
    
    func testRiskScoreDeletedWhenIsolating() {
        var risk: Double? = 7.5
        
        let isolationState = CurrentValueSubject<IsolationState, Never>(.noNeedToIsolate)
        
        let negotiator = RiskScoreNegotiator(
            saveRiskScore: { _ in },
            getIsolationState: { isolationState.value },
            isolationState: isolationState.eraseToAnyPublisher(),
            deleteRiskScore: { risk = nil }
        )
        
        let cancellable = negotiator.deleteRiskIfIsolating()
        defer { cancellable.cancel() }
        
        XCTAssertNotNil(risk)
        
        isolationState.send(.isolate(Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false))))
        
        XCTAssertNil(risk)
    }
}
