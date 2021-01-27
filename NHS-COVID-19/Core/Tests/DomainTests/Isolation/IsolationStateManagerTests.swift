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
        var isolationState = IsolationLogicalState.isolating(Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false, testkitType: nil, isSelfDiagnosed: true)), endAcknowledged: false, startAcknowledged: false)
    }
    
    private let day = LocalDay(
        gregorianDay: GregorianDay(year: 2020, month: 3, day: 17),
        timeZone: TimeZone(secondsFromGMT: .random(in: 100 ... 1000))!
    )
    
    var stateInfoSubject: CurrentValueSubject<IsolationStateInfo?, Never>!
    var daySubject: CurrentValueSubject<LocalDay, Never>!
    
    private var manager: IsolationStateManager!
    private var testState: TestState!
    
    override func setUp() {
        super.setUp()
        
        stateInfoSubject = CurrentValueSubject<IsolationStateInfo?, Never>(nil)
        daySubject = CurrentValueSubject<LocalDay, Never>(LocalDay(date: Date(), timeZone: .utc))
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
    
    func testRespondingToInitialBatchOfInfosReceived() {
        var info = IsolationStateInfo(isolationInfo: .empty, configuration: .default)
        info.configuration.indexCaseSinceSelfDiagnosisOnset = 18
        stateInfoSubject.send(info)
        daySubject.send(day)
        
        TS.assert(manager.state, equals: testState.isolationState)
        TS.assert(testState.requestedStateInfo, equals: info)
        TS.assert(testState.requestedCalendarInfo, equals: day)
    }
    
    func testRespondingToChangesInInfosReceived() {
        var info = IsolationStateInfo(isolationInfo: .empty, configuration: .default)
        let day2 = day.advanced(by: 1)
        info.configuration.indexCaseSinceSelfDiagnosisOnset = 18
        stateInfoSubject.send(info)
        daySubject.send(day)
        
        info.configuration.indexCaseSinceSelfDiagnosisOnset = 20
        
        stateInfoSubject.send(info)
        
        daySubject.send(day2)
        
        TS.assert(manager.state, equals: testState.isolationState)
        TS.assert(testState.requestedStateInfo, equals: info)
        TS.assert(testState.requestedCalendarInfo, equals: day2)
    }
    
    private func calculateState(_ stateInfo: IsolationStateInfo?, day: LocalDay) -> IsolationLogicalState {
        testState.requestedStateInfo = stateInfo
        testState.requestedCalendarInfo = day
        testState.callbackCount += 1
        return testState.isolationState
    }
    
}
