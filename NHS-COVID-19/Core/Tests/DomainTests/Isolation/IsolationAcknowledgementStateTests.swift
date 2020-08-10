//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import TestSupport
import XCTest
@testable import Domain

class IsolationAcknowledgementStateTests: XCTestCase {
    
    func testAcknowledgementNotNeededWhenNotIsolating() throws {
        let state = IsolationAcknowledgementState(
            logicalState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            now: Date(),
            acknowledgeStart: {},
            acknowledgeEnd: {}
        )
        
        guard case .notNeeded = state else {
            throw TestError("Unexpected state \(state)")
        }
    }
    
    func testAcknowledgementNeededAfterIsolation() throws {
        let day = LocalDay.today
        
        var callbackCount = 0
        let isolation = Isolation(untilStartOfDay: day, reason: .contactCase)
        let state = IsolationAcknowledgementState(
            logicalState: .isolationFinishedButNotAcknowledged(isolation),
            now: Date(),
            acknowledgeStart: {}
        ) {
            callbackCount += 1
        }
        
        guard case .neededForEnd(let actual, let acknowledge) = state else {
            throw TestError("Unexpected state \(state)")
        }
        
        TS.assert(actual, equals: isolation)
        
        TS.assert(callbackCount, equals: 0)
        acknowledge()
        TS.assert(callbackCount, equals: 1)
    }
    
    func testAcknowledgementNeededAtStartOfIsolationWhenContactCase() throws {
        let day = LocalDay.today
        
        var callbackCount = 0
        let isolation = Isolation(untilStartOfDay: day, reason: .contactCase)
        let state = IsolationAcknowledgementState(
            logicalState: .isolating(isolation, endAcknowledged: false, startAcknowledged: false),
            now: Date(),
            acknowledgeStart: {
                callbackCount += 1
            },
            acknowledgeEnd: {}
        )
        
        guard case .neededForStart(let actual, let acknowledge) = state else {
            throw TestError("Unexpected state \(state)")
        }
        
        TS.assert(actual, equals: isolation)
        
        TS.assert(callbackCount, equals: 0)
        acknowledge()
        TS.assert(callbackCount, equals: 1)
    }
    
    func testAcknowledgementNeededForEndOfIsolationWhenStartIsAcknowledged() throws {
        let day = LocalDay.today
        
        var callbackCount = 0
        let isolation = Isolation(untilStartOfDay: day, reason: .contactCase)
        let state = IsolationAcknowledgementState(
            logicalState: .isolating(isolation, endAcknowledged: false, startAcknowledged: true),
            now: Date(),
            acknowledgeStart: {}
        ) {
            callbackCount += 1
        }
        
        guard case .neededForEnd(let actual, let acknowledge) = state else {
            throw TestError("Unexpected state \(state)")
        }
        
        TS.assert(actual, equals: isolation)
        
        TS.assert(callbackCount, equals: 0)
        acknowledge()
        TS.assert(callbackCount, equals: 1)
    }
    
    func testAcknowledgementNotNeededWhenAcknowledgedStartAndEnd() throws {
        let day = LocalDay.today
        
        let isolation = Isolation(untilStartOfDay: day, reason: .contactCase)
        let state = IsolationAcknowledgementState(
            logicalState: .isolating(isolation, endAcknowledged: true, startAcknowledged: true),
            now: Date(),
            acknowledgeStart: {},
            acknowledgeEnd: {}
        )
        
        guard case .notNeeded = state else {
            throw TestError("Unexpected state \(state)")
        }
    }
    
    func testAcknowledgementNotNeededWhenIsolatingAndNotAboutToEnd() throws {
        let today = LocalDay(year: 2020, month: 3, day: 14, timeZone: .current)
        let endDay = LocalDay(year: 2020, month: 3, day: 17, timeZone: .current)
        
        let state = IsolationAcknowledgementState(
            logicalState: .isolating(Isolation(untilStartOfDay: endDay, reason: .indexCase(hasPositiveTestResult: false)), endAcknowledged: false, startAcknowledged: true),
            now: today.startOfDay,
            acknowledgeStart: {},
            acknowledgeEnd: {}
        )
        
        guard case .notNeeded = state else {
            throw TestError("Unexpected state \(state)")
        }
    }
    
    func testAcknowledgementNotNeededWhenIsolatingAndNotAboutToEndSlightlyMoreThanThreshold() throws {
        let endDay = LocalDay(year: 2020, month: 3, day: 17, timeZone: .current)
        let now = endDay.startOfDay.advanced(by: -(3.1 * 3600)) // slightly more than 3 hrs.
        
        let state = IsolationAcknowledgementState(
            logicalState: .isolating(Isolation(untilStartOfDay: endDay, reason: .indexCase(hasPositiveTestResult: false)), endAcknowledged: false, startAcknowledged: true),
            now: now,
            acknowledgeStart: {},
            acknowledgeEnd: {}
        )
        
        guard case .notNeeded = state else {
            throw TestError("Unexpected state \(state)")
        }
    }
    
    func testAcknowledgementNeededWhenIsolatingAndEndLessThanThresholdAway() throws {
        let endDay = LocalDay(year: 2020, month: 3, day: 17, timeZone: .current)
        let now = endDay.startOfDay.advanced(by: -(2.8 * 3600)) // slightly less than 3 hrs.
        
        let isolation = Isolation(untilStartOfDay: endDay, reason: .indexCase(hasPositiveTestResult: false))
        var callbackCount = 0
        let state = IsolationAcknowledgementState(
            logicalState: .isolating(isolation, endAcknowledged: false, startAcknowledged: true),
            now: now,
            acknowledgeStart: {}
        ) {
            callbackCount += 1
        }
        
        guard case .neededForEnd(let actual, let acknowledge) = state else {
            throw TestError("Unexpected state \(state)")
        }
        
        TS.assert(actual, equals: isolation)
        
        TS.assert(callbackCount, equals: 0)
        acknowledge()
        TS.assert(callbackCount, equals: 1)
    }
    
    func testAcknowledgementNotNeededWhenIsolatingEndLessThanThresholdAwayButAlreadyAcknowledged() throws {
        let endDay = LocalDay(year: 2020, month: 3, day: 17, timeZone: .current)
        let now = endDay.startOfDay.advanced(by: -(2.8 * 3600)) // slightly less than 3 hrs.
        
        let state = IsolationAcknowledgementState(
            logicalState: .isolating(Isolation(untilStartOfDay: endDay, reason: .indexCase(hasPositiveTestResult: false)), endAcknowledged: true, startAcknowledged: true),
            now: now,
            acknowledgeStart: {},
            acknowledgeEnd: {}
        )
        
        guard case .notNeeded = state else {
            throw TestError("Unexpected state \(state)")
        }
    }
    
}
