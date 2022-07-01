//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

extension RawState {

    static var onboardedRawState: CurrentValueSubject<RawState, Never> {
        let onboardedRawState = RawState(
            appAvailability: AppAvailabilityMetadata(titles: [:], descriptions: [:], state: .available),
            completedOnboardingForCurrentSession: false,
            exposureState: ExposureNotificationStateController.CombinedState(
                activationState: .activated,
                authorizationState: .authorized,
                exposureNotificationState: .active,
                isEnabled: true
            ),
            userNotificationsStatus: .authorized,
            postcodeState: .postcodeAndLocalAuthority,
            shouldRecommendUpdate: true,
            shouldShowPolicyUpdate: false
        )
        XCTAssert(onboardedRawState.isOnboarded)
        return CurrentValueSubject<RawState, Never>(onboardedRawState)
    }

    static var notOnboardedRawState: CurrentValueSubject<RawState, Never> {
        let notOnboardedRawState = RawState(
            appAvailability: AppAvailabilityMetadata(titles: [:], descriptions: [:], state: .available),
            completedOnboardingForCurrentSession: false,
            exposureState: ExposureNotificationStateController.CombinedState(
                activationState: .activated,
                authorizationState: .authorized,
                exposureNotificationState: .active,
                isEnabled: true
            ),
            userNotificationsStatus: .unknown,
            postcodeState: .empty,
            shouldRecommendUpdate: true,
            shouldShowPolicyUpdate: false
        )
        XCTAssertFalse(notOnboardedRawState.isOnboarded)
        return CurrentValueSubject<RawState, Never>(notOnboardedRawState)
    }
}

class MetricReporterTests: XCTestCase {
    private var currentDate: Date!
    private var collector: MetricCollector!
    private var state: MetricsState!
    private var creator: MetricUploadChunkCreator!
    private var reporter: MetricReporter!
    private var encryptedStore: MockEncryptedStore!
    private static let appVersion = "3.0.0"

    override func setUp() {

        currentDate = Date()
        encryptedStore = MockEncryptedStore()

        state = MetricsState()

        let currentDateProvider = MockDateProvider { self.currentDate }
        let appInfo = AppInfo(bundleId: .random(), version: Self.appVersion, buildNumber: "1")
        let postcode = "CF71"
        let authority = "W06000014"
        let country: Country = .wales
        let isFeatureEnabled = true

        collector = MetricCollector(
            encryptedStore: encryptedStore,
            currentDateProvider: currentDateProvider,
            enabled: state
        )

        creator = MetricUploadChunkCreator(
            collector: collector,
            appInfo: appInfo,
            getPostcode: { postcode },
            getLocalAuthority: { authority },
            getCountry: { country },
            currentDateProvider: currentDateProvider,
            isFeatureEnabled: { _ in isFeatureEnabled }
        )

        reporter = MetricReporter(
            client: MockHTTPClient(),
            encryptedStore: encryptedStore,
            currentDateProvider: currentDateProvider,
            appInfo: appInfo,
            getPostcode: { postcode },
            getLocalAuthority: { authority },
            getHouseKeepingDayDuration: { DayDuration(14) },
            metricCollector: collector,
            metricChunkCreator: creator,
            isFeatureEnabled: { _ in isFeatureEnabled },
            getCountry: { country }
        )

        // reset the onboarding completed flag
        state.set(rawState: RawState.notOnboardedRawState.domainProperty())
    }

    private func insertCheckIn() {

        currentDate = Date(timeIntervalSinceReferenceDate: 1000)
        collector.record(.checkedIn)
    }

    private func confirmCheckInExists() {
        let actual = encryptedStore.stored["metrics"]?.normalizingJSON()

        let expected = """
        {
            "entries": [
                { "name": "checkedIn", "date": 1000 }
            ]
        }
        """.normalizedJSON()

        TS.assert(actual, equals: expected)
    }

    private func confirmCheckInDoesntExist() {
        let actual = encryptedStore.stored["metrics"]?.normalizingJSON()

        let expected = """
        {
            "entries": [
            ],
            "latestWindowEnd": 172800
        }
        """.normalizedJSON()

        TS.assert(actual, equals: expected)
    }

    private func confirmNoEventsRecorded() {
        let actual = encryptedStore.stored["metrics"]?.normalizingJSON()
        XCTAssertNil(actual)
    }

    func testUploadBeforeOnboarding() throws {

        insertCheckIn() // insert an event

        currentDate = currentDate.advanced(by: 2 * 24 * 60 * 60) // advance the clock

        _ = reporter.uploadMetrics() // background task triggers, attempts an upload...

        confirmNoEventsRecorded() // confirm nothing in the event store

        _ = reporter.uploadMetrics() // background task triggers, attempts an upload...

        confirmNoEventsRecorded() // confirm nothing in the event store
    }

    func testUploadAfterOnboarding() throws {

        insertCheckIn() // insert an event

        currentDate = currentDate.advanced(by: 2 * 24 * 60 * 60) // advance the clock

        // simulate onboarding completed
        state.set(rawState: RawState.onboardedRawState.domainProperty())

        confirmNoEventsRecorded() // confirm nothing in the event store

        _ = reporter.uploadMetrics() // background task triggers, attempts an upload...

        insertCheckIn() // insert an event

        confirmCheckInExists() // confirm that it was not consumed
    }
}
