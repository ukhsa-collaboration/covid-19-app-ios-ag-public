//
// Copyright © 2021 DHSC. All rights reserved.
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
        if let state = state {
            XCTFail("Wrong state: got \(state)")
        }
    }
    
    func testPositiveTestResultAckNeeded() throws {
        let date = Date()
        let context = makeRunningAppContext(
            isolationAckState: .notNeeded,
            testResultAckState: .neededForPositiveResultContinueToIsolate(acknowledge: {}, isolationEndDate: date, requiresConfirmatoryTest: false),
            riskyCheckInsAckState: .notNeeded
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        guard case .neededForPositiveResultContinueToIsolate(_, let isolationEndDate, _) = state else {
            XCTFail("Wrong state: got \(String(describing: state))")
            return
        }
        XCTAssertEqual(date, isolationEndDate)
    }
    
    func testNegativeTestResultAckNeededNoIsolation() throws {
        let context = makeRunningAppContext(
            isolationAckState: .notNeeded,
            testResultAckState: .neededForNegativeResultNotIsolating(acknowledge: {}),
            riskyCheckInsAckState: .notNeeded
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        guard case .neededForNegativeResultNotIsolating = state else {
            XCTFail("Wrong state: got \(String(describing: state))")
            return
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
        guard case .neededForNegativeResultContinueToIsolate(_, let isolationEndDate) = state else {
            XCTFail("Wrong state: got \(String(describing: state))")
            return
        }
        XCTAssertEqual(date, isolationEndDate)
    }
    
    func testIsolationEndAckNeeded() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: false, isPendingConfirmation: false), contactCaseInfo: nil)
        )
        let context = makeRunningAppContext(
            isolationAckState: .neededForEnd(isolation, acknowledge: {}),
            testResultAckState: .notNeeded,
            riskyCheckInsAckState: .notNeeded
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        guard case .neededForEndOfIsolation(_, let isolationEndDate, let showAdvisory) = state else {
            XCTFail("Wrong state: got \(String(describing: state))")
            return
        }
        XCTAssertEqual(isolationEndDate, isolation.endDate)
        XCTAssertEqual(showAdvisory, isolation.isIndexCase)
    }
    
    func testPositiveTestResultOverIsolationEndAckNeeded() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)
        )
        
        let context = makeRunningAppContext(
            isolationAckState: .neededForEnd(isolation, acknowledge: {}),
            testResultAckState: .neededForPositiveResultContinueToIsolate(acknowledge: {}, isolationEndDate: Date(), requiresConfirmatoryTest: false),
            riskyCheckInsAckState: .needed(acknowledge: {}, venueName: "Venue", checkInDate: Date(), resolution: .warnAndInform)
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        
        guard case .neededForPositiveResultContinueToIsolate = state else {
            XCTFail("Wrong state: got \(String(describing: state))")
            return
        }
    }
    
    func testNegativeTestResultOverIsolationEndAckNeeded() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)
        )
        
        let context = makeRunningAppContext(
            isolationAckState: .neededForEnd(isolation, acknowledge: {}),
            testResultAckState: .neededForNegativeResultNotIsolating(acknowledge: {}),
            riskyCheckInsAckState: .needed(acknowledge: {}, venueName: "Venue", checkInDate: Date(), resolution: .warnAndInform)
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        
        guard case .neededForNegativeResultNotIsolating = state else {
            XCTFail("Wrong state: got \(String(describing: state))")
            return
        }
    }
    
    func testIsolationStartAckExposureDetectionNeeded() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(optOutOfIsolationDay: nil))
        )
        
        let context = makeRunningAppContext(
            isolationAckState: .neededForStart(isolation, acknowledge: {}),
            testResultAckState: .notNeeded,
            riskyCheckInsAckState: .notNeeded
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        
        guard case .neededForStartOfIsolationExposureDetection = state else {
            XCTFail("Wrong state: got \(String(describing: state))")
            return
        }
    }
    
    func testRiskyVenueAlertNeeded() throws {
        let expectedVenueName = "Venue"
        let expectedCheckInDate = Date()
        let context = makeRunningAppContext(
            isolationAckState: .notNeeded,
            testResultAckState: .notNeeded,
            riskyCheckInsAckState: .needed(acknowledge: {}, venueName: expectedVenueName, checkInDate: expectedCheckInDate, resolution: .warnAndInform)
        )
        
        let state = try AcknowledgementNeededState.makeAcknowledgementState(context: context).await().get()
        
        guard case let .neededForRiskyVenue(_, venueName, checkInDate) = state else {
            XCTFail("Wrong state: got \(String(describing: state))")
            return
        }
        XCTAssertEqual(venueName, expectedVenueName)
        XCTAssertEqual(checkInDate, expectedCheckInDate)
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
            openAppStore: {},
            openURL: { _ in },
            selfDiagnosisManager: MockSelfDiagnosisManager(),
            isolationState: Just(.noNeedToIsolate()).domainProperty(), testInfo: Just(nil).domainProperty(),
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
            appReviewPresenter: MockAppReviewPresenter(reviewController: MockStoreReviewController(), currentDateProvider: currentDateProvider),
            getLocalAuthorities: { _ in
                .success(Set<LocalAuthority>())
            },
            storeLocalAuthorities: { _, _ in
                .success(())
            },
            isolationPaymentState: .constant(.disabled),
            currentLocaleConfiguration: Just(.systemPreferred).eraseToAnyPublisher().domainProperty(),
            storeNewLanguage: { _ in },
            homeAnimationsStore: HomeAnimationsStore(store: MockEncryptedStore()),
            shouldShowDailyContactTestingInformFeature: { true },
            dailyContactTestingEarlyTerminationSupport: { .disabled },
            diagnosisKeySharer: .constant(nil),
            localInformation: .constant(nil),
            userNotificationManaging: MockUserNotificationsManager()
        )
    }
    
    private class MockVirologyTestingManager: VirologyTestingManaging {
        func isFollowUpTestRequired() -> AnyPublisher<Bool, Never> {
            Just(false).eraseToAnyPublisher()
        }
        
        func didClearBookFollowUpTest() {}
        
        var didReceiveUnknownTestResult: Bool = false
        
        func acknowledgeUnknownTestResult() {}
        
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
    
    private class MockSelfDiagnosisManager: SelfDiagnosisManaging {
        public var threshold: Double?
        
        public func fetchQuestionnaire() -> AnyPublisher<SymptomsQuestionnaire, NetworkRequestError> {
            return Future<SymptomsQuestionnaire, NetworkRequestError> { promise in
                promise(.success(SymptomsQuestionnaire(symptoms: [], riskThreshold: 0.0, dateSelectionWindow: 0)))
            }.eraseToAnyPublisher()
        }
        
        public func evaluateSymptoms(symptoms: [(Symptom, Bool)], onsetDay: GregorianDay?, threshold: Double) -> (IsolationState, Bool?) {
            return (.noNeedToIsolate(), nil)
        }
    }
    
    private class MockAppReviewPresenter: AppReviewPresenting {
        private let reviewController: StoreReviewControlling
        private let currentDateProvider: DateProviding
        
        func presentReview() {
            reviewController.requestAppReview()
        }
        
        init(reviewController: StoreReviewControlling, currentDateProvider: DateProviding) {
            self.reviewController = reviewController
            self.currentDateProvider = currentDateProvider
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
