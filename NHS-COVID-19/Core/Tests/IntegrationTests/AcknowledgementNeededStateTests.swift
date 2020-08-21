//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Scenarios
import XCTest
@testable import Domain
@testable import Integration

class AcknowledgementNeededStateTests: XCTestCase {
    
    func testNotNeeded() throws {
        let context = makeRunningAppContext(
            isolationAckState: .notNeeded,
            testResultAckState: .notNeeded,
            riskyCheckInsAckState: .notNeeded
        )
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        if case .notNeeded = state {
            XCTAssert(true)
        }
    }
    
    func testPositiveTestResultAckNeeded() throws {
        let date = Date()
        let context = makeRunningAppContext(
            isolationAckState: .notNeeded,
            testResultAckState: .neededForPositiveResult(acknowledge: { Empty().eraseToAnyPublisher() }, isolationEndDate: date),
            riskyCheckInsAckState: .notNeeded
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        if case .positiveTestResultAckNeeded(_, let isolationEndDate) = state {
            XCTAssert(true)
            XCTAssertEqual(date, isolationEndDate)
        }
    }
    
    func testNegativeTestResultAckNeededNoIsolation() throws {
        let context = makeRunningAppContext(
            isolationAckState: .notNeeded,
            testResultAckState: .neededForNegativeResultNoIsolation(acknowledge: {}),
            riskyCheckInsAckState: .notNeeded
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        if case .negativeTestResultAckNeeded = state {
            XCTAssert(true)
        }
    }
    
    func testNegativeTestResultAckNeededWithIsolation() throws {
        let date = Date()
        let context = makeRunningAppContext(
            isolationAckState: .notNeeded,
            testResultAckState: .neededForNegativeResult(acknowledge: {}, isolationEndDate: date),
            riskyCheckInsAckState: .notNeeded
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        if case .negativeTestResultAckNeeded(_, let isolationEndDate) = state {
            XCTAssert(true)
            XCTAssertEqual(date, isolationEndDate)
        }
    }
    
    func testIsolationEndAckNeeded() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: .indexCase(hasPositiveTestResult: false)
        )
        let context = makeRunningAppContext(
            isolationAckState: .neededForEnd(isolation, acknowledge: {}),
            testResultAckState: .neededForNegativeResultNoIsolation(acknowledge: {}),
            riskyCheckInsAckState: .notNeeded
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        if case .isolationEndAckNeeded(_, let isolationEndDate, let showAdvisory) = state {
            XCTAssert(true)
            XCTAssertEqual(isolationEndDate, isolation.endDate)
            XCTAssertEqual(showAdvisory, isolation.isIndexCase)
        }
    }
    
    func testPositiveTestResultOverIsolationEndAckNeeded() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: .indexCase(hasPositiveTestResult: false)
        )
        
        let context = makeRunningAppContext(
            isolationAckState: .neededForEnd(isolation, acknowledge: {}),
            testResultAckState: .neededForPositiveResult(acknowledge: { Empty().eraseToAnyPublisher() }, isolationEndDate: Date()),
            riskyCheckInsAckState: .needed(acknowledge: {}, venueName: "Venue", checkInDate: Date())
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        
        if case .positiveTestResultAckNeeded = state {
            XCTAssert(true)
        }
    }
    
    func testNegativeTestResultOverIsolationEndAckNeeded() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: .indexCase(hasPositiveTestResult: false)
        )
        
        let context = makeRunningAppContext(
            isolationAckState: .neededForEnd(isolation, acknowledge: {}),
            testResultAckState: .neededForNegativeResultNoIsolation(acknowledge: {}),
            riskyCheckInsAckState: .needed(acknowledge: {}, venueName: "Venue", checkInDate: Date())
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        
        if case .negativeTestResultAckNeeded = state {
            XCTAssert(true)
        }
    }
    
    func testRiskyVenueAlertNeeded() throws {
        let expectedVenueName = "Venue"
        let expectedCheckInDate = Date()
        let context = makeRunningAppContext(
            isolationAckState: .notNeeded,
            testResultAckState: .notNeeded,
            riskyCheckInsAckState: .needed(acknowledge: {}, venueName: expectedVenueName, checkInDate: expectedCheckInDate)
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        
        if case let .riskyVenueNeeded(_, venueName, checkInDate) = state,
            venueName == expectedVenueName,
            checkInDate == expectedCheckInDate {
            XCTAssert(true)
        }
    }
    
    private func makeRunningAppContext(
        isolationAckState: IsolationAcknowledgementState,
        testResultAckState: TestResultAcknowledgementState,
        riskyCheckInsAckState: RiskyCheckInsAcknowledgementState
    ) -> RunningAppContext {
        RunningAppContext(
            checkInContext: nil,
            postcodeStore: nil,
            openSettings: {},
            openURL: { _ in },
            selfDiagnosisManager: nil,
            isolationState: Just(.noNeedToIsolate).domainProperty(), testInfo: Just(nil).domainProperty(),
            isolationAcknowledgementState: Result.success(isolationAckState).publisher.eraseToAnyPublisher(),
            exposureNotificationStateController: ExposureNotificationStateController(
                manager: MockExposureNotificationManager()
            ),
            virologyTestOrderInfoProvider: MockVirologyTestOrderInfoProvider(),
            testResultAcknowledgementState: Result.success(testResultAckState).publisher.eraseToAnyPublisher(),
            symptomsDateAndEncounterDateProvider: MockSymptomsOnsetDateAndEncounterDateProvider(),
            deleteAllData: {},
            riskyCheckInsAcknowledgementState: Result.success(riskyCheckInsAckState).publisher.eraseToAnyPublisher(),
            qrCodeScanner: MockQRCodeScanner()
        )
    }
    
    private class MockVirologyTestOrderInfoProvider: VirologyTestingTestOrderInfoProviding {
        func provideTestResult() -> (TestResult, Date)? {
            nil
        }
        
        func provideTestOrderInfo() -> AnyPublisher<TestOrderInfo, NetworkRequestError> {
            Empty().eraseToAnyPublisher()
        }
    }
    
    private class MockSymptomsOnsetDateAndEncounterDateProvider: SymptomsOnsetDateAndEncounterDateProviding {
        func provideSymptomsOnsetDate() -> Date? {
            nil
        }
        
        func provideEncounterDate() -> Date? {
            nil
        }
    }
}
