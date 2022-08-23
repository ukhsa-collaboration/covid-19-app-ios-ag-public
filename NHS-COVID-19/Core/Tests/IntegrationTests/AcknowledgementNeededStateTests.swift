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
            reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(exposureDay: .today))
        )

        let context = makeRunningAppContext(
            isolationAckState: .neededForStartContactIsolation(isolation, acknowledge: { _ in }),
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
            shouldShowVenueCheckIn: false,
            shouldShowTestingForCOVID19: false,
            shouldShowSelfIsolationHubEngland: false,
            shouldShowSelfIsolationHubWales: false,
            shouldShowEnglandOptOutFlow: false,
            shouldShowWalesOptOutFlow: false,
            shouldShowGuidanceHubEngland: false,
            shouldShowGuidanceHubWales: false,
            postcodeInfo: .constant(nil),
            country: Just(.england).eraseToAnyPublisher().domainProperty(),
            bluetoothOff: .constant(false),
            bluetoothOffAcknowledgementNeeded: Just(false).eraseToAnyPublisher(),
            bluetoothOffAcknowledgedCallback: {},
            openSettings: {},
            openAppStore: {},
            openURL: { _ in },
            selfDiagnosisManager: MockSelfDiagnosisManager(),
            symptomsCheckerManager: MockSymptomsCheckerManager(),
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
            diagnosisKeySharer: .constant(nil),
            localInformation: .constant(nil),
            userNotificationManaging: MockUserNotificationsManager(),
            shouldShowBookALabTest: .constant(false),
            contactCaseOptOutQuestionnaire: ContactCaseOptOutQuestionnaire(country: .constant(.england)),
            contactCaseIsolationDuration: .constant(DayDuration(11)),
            shouldShowLocalStats: true,
            localCovidStatsManager: MockLocalStatsManager(),
            newLabelForLongCovidEnglandState: NewLabelState(newLabelForName: "OpenedNewLongCovidInfoInWalesV4_35", setByCoordinator: true),
            newLabelForLongCovidWalesState: NewLabelState(newLabelForName: "OpenedNewLongCovidInfoInEnglandV4_35", setByCoordinator: true)
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

        func provideExposureDetails() -> (encounterDate: Date, notificationDate: Date, optOutOfIsolationDate: Date?)? {
            nil
        }
    }

    private class MockSelfDiagnosisManager: SelfDiagnosisManaging {

        var threshold: Double?

        func fetchQuestionnaire() -> AnyPublisher<SymptomsQuestionnaire, NetworkRequestError> {
            return Future<SymptomsQuestionnaire, NetworkRequestError> { promise in
                promise(.success(SymptomsQuestionnaire(
                    symptoms: [],
                    cardinal: CardinalSymptom(title: LocaleString(dictionaryLiteral: (.current, ""))),
                    noncardinal: NonCardinalSymptom(title: LocaleString(dictionaryLiteral: (.current, "")), description: LocaleString(dictionaryLiteral: (.current, ""))),
                    riskThreshold: 0.0,
                    dateSelectionWindow: 0,
                    isSymptomaticSelfIsolationForWalesEnabled: false)))
            }.eraseToAnyPublisher()
        }

        func evaluate(selectedSymptoms: [Symptom], onsetDay: GregorianDay?, threshold: Double, symptomaticSelfIsolationEnabled: Bool) -> SelfDiagnosisEvaluation {
            .noSymptoms
        }

    }

    private class MockSymptomsCheckerManager: SymptomsCheckerManaging {

        let symptomsCheckerStore = SymptomsCheckerStore(store: MockEncryptedStore())
        private let symptomCheckerAdviceHandler = SymptomCheckerAdviceHandler()

        func store(shouldTryToStayAtHome: Bool) {
            let currentDay: GregorianDay = .today
            symptomsCheckerStore.save(lastCompletedSymptomsQuestionnaireDay: currentDay, toldToStayHome: shouldTryToStayAtHome)
        }

        func invoke(symptomCheckerQuestions: SymptomCheckerQuestions) -> SymptomCheckerAdviceResult? {
            symptomCheckerAdviceHandler.invoke(symptomCheckerQuestions: symptomCheckerQuestions)
        }

        func fetchQuestionnaire() -> AnyPublisher<SymptomsQuestionnaire, NetworkRequestError> {
            return Future<SymptomsQuestionnaire, NetworkRequestError> { promise in
                promise(.success(SymptomsQuestionnaire(
                    symptoms: [],
                    cardinal: CardinalSymptom(title: LocaleString(dictionaryLiteral: (.current, ""))),
                    noncardinal: NonCardinalSymptom(title: LocaleString(dictionaryLiteral: (.current, "")), description: LocaleString(dictionaryLiteral: (.current, ""))),
                    riskThreshold: 0.0,
                    dateSelectionWindow: 0,
                    isSymptomaticSelfIsolationForWalesEnabled: false)))
            }.eraseToAnyPublisher()
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

    typealias StatsValue = LocalCovidStatsDaily.LocalAuthorityStats.Value
    typealias Direction = LocalCovidStatsDaily.Direction

    private class MockLocalStatsManager: LocalCovidStatsManaging {

        func fetchLocalCovidStats() -> AnyPublisher<LocalCovidStatsDaily, NetworkRequestError> {

            let formatter = ISO8601DateFormatter()
            let date = { (string: String) throws -> Date in
                try XCTUnwrap(formatter.date(from: string))
            }

            let day = GregorianDay(year: 2021, month: 11, day: 18)
            let dayOne = GregorianDay(year: 2021, month: 11, day: 13)
            return Future<LocalCovidStatsDaily, NetworkRequestError> { promise in
                promise(.success(try! LocalCovidStatsDaily(
                    lastFetch: date("2021-11-15T21:59:00Z"),
                    england: LocalCovidStatsDaily.CountryStats(newCasesBySpecimenDateRollingRate: 510.8, lastUpdate: dayOne),
                    wales: LocalCovidStatsDaily.CountryStats(newCasesBySpecimenDateRollingRate: nil, lastUpdate: dayOne),
                    lowerTierLocalAuthorities: [
                        LocalAuthorityId("E06000037"): LocalCovidStatsDaily.LocalAuthorityStats(
                            id: LocalAuthorityId("E06000037"),
                            name: "West Berkshire",
                            newCasesByPublishDateRollingSum: StatsValue(value: -771, lastUpdate: day),
                            newCasesByPublishDateChange: StatsValue(value: 207, lastUpdate: day),
                            newCasesByPublishDateDirection: StatsValue(value: .up, lastUpdate: day),
                            newCasesByPublishDate: StatsValue(value: 105, lastUpdate: day),
                            newCasesByPublishDateChangePercentage: StatsValue(value: 36.7, lastUpdate: day),
                            newCasesBySpecimenDateRollingRate: StatsValue(value: 289.5, lastUpdate: dayOne)
                        ),
                        LocalAuthorityId("E08000035"): LocalCovidStatsDaily.LocalAuthorityStats(
                            id: LocalAuthorityId("E08000035"),
                            name: "Leeds",
                            newCasesByPublishDateRollingSum: StatsValue(value: nil, lastUpdate: day),
                            newCasesByPublishDateChange: StatsValue(value: nil, lastUpdate: day),
                            newCasesByPublishDateDirection: StatsValue(value: nil, lastUpdate: day),
                            newCasesByPublishDate: StatsValue(value: nil, lastUpdate: day),
                            newCasesByPublishDateChangePercentage: StatsValue(value: nil, lastUpdate: day),
                            newCasesBySpecimenDateRollingRate: StatsValue(value: nil, lastUpdate: dayOne)
                        ),
                    ]
                )))
            }.eraseToAnyPublisher()
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
