//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine

import XCTest
@testable import Domain

class RiskScoreNegotiatorTests: XCTestCase {
    
    func testRiskScoreIsSavedWhenNotIsolating() {
        var riskInfo: RiskInfo?
        
        let negotiator = RiskScoreNegotiator(
            saveRiskScore: { riskInfo = $0 },
            getIsolationState: { .noNeedToIsolate },
            isolationState: Empty().eraseToAnyPublisher(),
            deleteRiskScore: {}
        )
        
        negotiator.receive(riskInfo: RiskInfo(riskScore: 7.5, day: .today))
        
        XCTAssertEqual(riskInfo, RiskInfo(riskScore: 7.5, day: .today))
    }
    
    func testRiskScoreIsNotSavedWhenIsolating() {
        var riskInfo: RiskInfo?
        
        let negotiator = RiskScoreNegotiator(
            saveRiskScore: { riskInfo = $0 },
            getIsolationState: { .isolate(Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false))) },
            isolationState: Empty().eraseToAnyPublisher(),
            deleteRiskScore: {}
        )
        
        negotiator.receive(riskInfo: RiskInfo(riskScore: 7.5, day: .today))
        
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
