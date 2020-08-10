//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import TestSupport
import XCTest
@testable import Domain

class IsolationStateManagerTests: XCTestCase {
    
    private struct TestState {
        var requestedStateInfo: IsolationStateInfo?
        var requestedCalendarInfo: LocalDay?
        var callbackCount = 0
        var isolationState = IsolationLogicalState.isolating(Isolation(untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false)), endAcknowledged: false, startAcknowledged: false)
    }
    
    private let stateInfoSubject = PassthroughSubject<IsolationStateInfo?, Never>()
    private let daySubject = PassthroughSubject<LocalDay, Never>()
    private let day = LocalDay(
        gregorianDay: GregorianDay(year: 2020, month: 3, day: 17),
        timeZone: TimeZone(secondsFromGMT: .random(in: 100 ... 1000))!
    )
    
    private var manager: IsolationStateManager!
    private var testState: TestState!
    
    override func setUp() {
        super.setUp()
        
        testState = TestState()
        manager = IsolationStateManager(
            isolationStateInfo: stateInfoSubject,
            day: daySubject,
            calculateState: calculateState
        )
        addTeardownBlock {
            self.manager = nil
        }
    }
    
    func testStateInitiallyIsNoNeedToIsolate() {
        // Shouldn’t really happen in practice, because `logicalState` publisher should emit immediately.
        
        TS.assert(manager.state, equals: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil))
    }
    
    func testRespondingToInitialBatchOfInfosReceived() {
        var info = IsolationStateInfo(isolationInfo: .empty, configuration: .default)
        info.configuration.indexCaseSinceSelfDiagnosisOnset = 18
        stateInfoSubject.send(info)
        daySubject.send(day)
        
        TS.assert(manager.state, equals: testState.isolationState)
        TS.assert(testState.requestedStateInfo, equals: info)
        TS.assert(testState.requestedCalendarInfo, equals: day)
        TS.assert(testState.callbackCount, equals: 1)
    }
    
    func testRespondingToChangesInInfosReceived() {
        var info = IsolationStateInfo(isolationInfo: .empty, configuration: .default)
        info.configuration.indexCaseSinceSelfDiagnosisOnset = 18
        stateInfoSubject.send(info)
        daySubject.send(day)
        
        TS.assert(testState.callbackCount, equals: 1)
        
        info.configuration.indexCaseSinceSelfDiagnosisOnset = 20
        
        stateInfoSubject.send(info)
        TS.assert(testState.callbackCount, equals: 2)
        
        daySubject.send(day)
        TS.assert(testState.callbackCount, equals: 3)
        
        TS.assert(manager.state, equals: testState.isolationState)
        TS.assert(testState.requestedStateInfo, equals: info)
        TS.assert(testState.requestedCalendarInfo, equals: day)
    }
    
    private func calculateState(_ stateInfo: IsolationStateInfo?, day: LocalDay) -> IsolationLogicalState {
        testState.requestedStateInfo = stateInfo
        testState.requestedCalendarInfo = day
        testState.callbackCount += 1
        return testState.isolationState
    }
    
}
