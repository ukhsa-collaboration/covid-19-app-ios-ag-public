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
        if case .neededForPositiveResultContinueToIsolate(_, let isolationEndDate) = state {
            XCTAssert(true)
            XCTAssertEqual(date, isolationEndDate)
        }
    }
    
    func testNegativeTestResultAckNeededNoIsolation() throws {
        let context = makeRunningAppContext(
            isolationAckState: .notNeeded,
            testResultAckState: .neededForNegativeResultNotIsolating(acknowledge: {}),
            riskyCheckInsAckState: .notNeeded
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        if case .neededForNegativeResultContinueToIsolate = state {
            XCTAssert(true)
        }
    }
    
    func testNegativeTestResultAckNeededWithIsolation() throws {
        let date = Date()
        let context = makeRunningAppContext(
            isolationAckState: .notNeeded,
            testResultAckState: .neededForNegativeResultContinueToIsolate(acknowledge: {}, isolationEndDate: date),
            riskyCheckInsAckState: .notNeeded
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        if case .neededForNegativeResultContinueToIsolate(_, let isolationEndDate) = state {
            XCTAssert(true)
            XCTAssertEqual(date, isolationEndDate)
        }
    }
    
    func testIsolationEndAckNeeded() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true)
        )
        let context = makeRunningAppContext(
            isolationAckState: .neededForEnd(isolation, acknowledge: {}),
            testResultAckState: .neededForNegativeResultNotIsolating(acknowledge: {}),
            riskyCheckInsAckState: .notNeeded
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        if case .neededForEndOfIsolation(_, let isolationEndDate, let showAdvisory) = state {
            XCTAssert(true)
            XCTAssertEqual(isolationEndDate, isolation.endDate)
            XCTAssertEqual(showAdvisory, isolation.isIndexCase)
        }
    }
    
    func testPositiveTestResultOverIsolationEndAckNeeded() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true)
        )
        
        let context = makeRunningAppContext(
            isolationAckState: .neededForEnd(isolation, acknowledge: {}),
            testResultAckState: .neededForPositiveResult(acknowledge: { Empty().eraseToAnyPublisher() }, isolationEndDate: Date()),
            riskyCheckInsAckState: .needed(acknowledge: {}, venueName: "Venue", checkInDate: Date())
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        
        if case .neededForPositiveResultContinueToIsolate = state {
            XCTAssert(true)
        }
    }
    
    func testNegativeTestResultOverIsolationEndAckNeeded() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true)
        )
        
        let context = makeRunningAppContext(
            isolationAckState: .neededForEnd(isolation, acknowledge: {}),
            testResultAckState: .neededForNegativeResultNotIsolating(acknowledge: {}),
            riskyCheckInsAckState: .needed(acknowledge: {}, venueName: "Venue", checkInDate: Date())
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        
        if case .neededForNegativeResultContinueToIsolate = state {
            XCTAssert(true)
        }
    }
    
    func testIsolationStartAckRiskyVenueNeeded() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: .contactCase(.riskyVenue)
        )
        
        let context = makeRunningAppContext(
            isolationAckState: .neededForStart(isolation, acknowledge: {}),
            testResultAckState: .notNeeded,
            riskyCheckInsAckState: .notNeeded
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        
        if case .neededForStartOfIsolationRiskyVenue = state {
            XCTAssert(true)
        }
    }
    
    func testIsolationStartAckExposureDetectionNeeded() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: .contactCase(.exposureDetection)
        )
        
        let context = makeRunningAppContext(
            isolationAckState: .neededForStart(isolation, acknowledge: {}),
            testResultAckState: .notNeeded,
            riskyCheckInsAckState: .notNeeded
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        
        if case .neededForStartOfIsolationExposureDetection = state {
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
        
        if case let .neededForRiskyVenue(_, venueName, checkInDate) = state,
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
        let currentDateProvider = MockDateProvider()
        return RunningAppContext(
            checkInContext: nil,
            postcodeInfo: .constant(nil),
            country: Just(.england).eraseToAnyPublisher().domainProperty(),
            openSettings: {},
            openURL: { _ in },
            selfDiagnosisManager: nil,
            isolationState: Just(.noNeedToIsolate).domainProperty(), testInfo: Just(nil).domainProperty(),
            isolationAcknowledgementState: Result.success(isolationAckState).publisher.eraseToAnyPublisher(),
            exposureNotificationStateController: ExposureNotificationStateController(
                manager: MockExposureNotificationManager()
            ),
            virologyTestingManager: MockVirologyTestingManager(),
            testResultAcknowledgementState: Result.success(testResultAckState).publisher.eraseToAnyPublisher(),
            symptomsOnsetAndExposureDetailsProvider: MockSymptomsOnsetDateAndExposureDetailsProvider(),
            deleteAllData: {},
            deleteCheckIn: { _ in },
            riskyCheckInsAcknowledgementState: Result.success(riskyCheckInsAckState).publisher.eraseToAnyPublisher(),
            currentDateProvider: currentDateProvider,
            exposureNotificationReminder: ExposureNotificationReminder(),
            appReviewPresenter: AppReviewPresenter(checkInsStore: nil, reviewController: MockStoreReviewController(), currentDateProvider: currentDateProvider),
            isolationPaymentState: .constant(.disabled)
        )
    }
    
    private class MockVirologyTestingManager: VirologyTestingManaging {
        func linkExternalTestResult(with token: String) -> AnyPublisher<Void, LinkTestResultError> {
            Empty().eraseToAnyPublisher()
        }
        
        func provideTestOrderInfo() -> AnyPublisher<TestOrderInfo, NetworkRequestError> {
            Empty().eraseToAnyPublisher()
        }
    }
    
    private class MockSymptomsOnsetDateAndExposureDetailsProvider: SymptomsOnsetDateAndExposureDetailsProviding {
        func provideSymptomsOnsetDate() -> Date? {
            nil
        }
        
        func provideExposureDetails() -> (encounterDate: Date, notificationDate: Date)? {
            nil
        }
        
    }
}

private extension ExposureNotificationReminder {
    convenience init() {
        let manager = MockUserNotificationsManager()
        let controller = UserNotificationsStateController(manager: manager, notificationCenter: NotificationCenter())
        self.init(
            userNotificationManager: manager,
            userNotificationStateController: controller,
            currentDateProvider: MockDateProvider(),
            exposureNotificationEnabled: Just(true).eraseToAnyPublisher()
        )
    }
}
