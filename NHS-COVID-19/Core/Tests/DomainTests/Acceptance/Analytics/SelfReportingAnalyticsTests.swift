//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Foundation
import XCTest
import ExposureNotification
@testable import Domain

@available(iOS 13.7, *)
class SelfReportingAnalyticsTests: AnalyticsTests {
    var selfReportingManager: SelfReportingManaging!

    override func setUpFunctionalities() {
        self.selfReportingManager = try! context().selfReportingManager
    }

    func testPositiveLfdSymptoms() {
        let today = $instance.currentDateProvider.currentGregorianDay(timeZone: .utc)

        assertAnalyticsPacketIsNormal()

        selfReportingManager.submit(
            testResult: .positive,
            testKitType: .rapidSelfReported,
            testDate: today,
            symptoms: true,
            onsetDay: today,
            nhsTest: true,
            reportedResult: true
        )

        assertOnFields { assertField in
            assertField.equals(expected: 1, \.receivedPositiveTestResult)
            assertField.equals(expected: 1, \.receivedPositiveSelfRapidTestResultEnteredManually)
            assertField.equals(expected: 1, \.isPositiveSelfLFDFree)
            assertField.equals(expected: 1, \.didHaveSymptomsBeforeReceivedTestResult)
            assertField.equals(expected: 1, \.didRememberOnsetSymptomsDateBeforeReceivedTestResult)
            assertField.equals(expected: 1, \.selfReportedPositiveSelfLFDOnGov)
            assertField.equals(expected: 1, \.completedSelfReportingTestFlow)
            assertField.isPresent(\.isIsolatingForTestedSelfRapidPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.equals(expected: 1, \.startedIsolation)
            assertField.isPresent(\.askedToShareExposureKeysInTheInitialFlow)
        }
    }

    func testPositiveLfdNoSymptoms() {
        assertAnalyticsPacketIsNormal()

        selfReportingManager.submit(
            testResult: .positive,
            testKitType: .labResult,
            testDate: $instance.currentDateProvider.currentGregorianDay(timeZone: .utc),
            symptoms: false,
            onsetDay: nil,
            nhsTest: nil,
            reportedResult: nil
        )

        assertOnFields { assertField in
            assertField.equals(expected: 1, \.receivedPositiveTestResult)
            assertField.equals(expected: 1, \.receivedPositiveTestResultEnteredManually)
            assertField.equals(expected: 0, \.didHaveSymptomsBeforeReceivedTestResult)
            assertField.equals(expected: 0, \.didRememberOnsetSymptomsDateBeforeReceivedTestResult)
            assertField.equals(expected: 0, \.selfReportedPositiveSelfLFDOnGov)
            assertField.equals(expected: 1, \.completedSelfReportingTestFlow)
            assertField.isPresent(\.isIsolatingForTestedPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.equals(expected: 1, \.startedIsolation)
            assertField.isPresent(\.askedToShareExposureKeysInTheInitialFlow)
        }
    }

    // this currently happens during an isolation and for the 14 days after isolation
    func testHasTestedPositiveLfdBackgroundTickPresentAfterSelfReporting() throws {
        // Current date: 1st Jan
        // Starting state: App running normally, not in isolation
        assertAnalyticsPacketIsNormal()
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan

        // reports positive test result on 2nd Jan
        // Isolation end date: 12th Jan
        selfReportingManager.submit(
            testResult: .positive,
            testKitType: .rapidSelfReported,
            testDate: $instance.currentDateProvider.currentGregorianDay(timeZone: .utc),
            symptoms: false,
            onsetDay: nil,
            nhsTest: true,
            reportedResult: true
        )

        // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
        // Now in isolation due to positive test result
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.receivedPositiveTestResult)
            assertField.equals(expected: 1, \.receivedPositiveSelfRapidTestResultEnteredManually)
            assertField.equals(expected: 1, \.isPositiveSelfLFDFree)
            assertField.equals(expected: 1, \.selfReportedPositiveSelfLFDOnGov)
            assertField.equals(expected: 1, \.completedSelfReportingTestFlow)
            assertField.isPresent(\.isIsolatingForTestedSelfRapidPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingBackgroundTick)

            assertField.equals(expected: 1, \.startedIsolation)
            assertField.isPresent(\.askedToShareExposureKeysInTheInitialFlow)
        }

        // Dates: 4th-13th Jan -> Analytics packets for: 3rd-12th Jan
        // Still in isolation
        assertOnFieldsForDateRange(dateRange: 4 ... 13) { assertField in
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForTestedSelfRapidPositiveBackgroundTick)
            assertField.isNil(\.hasTestedPositiveBackgroundTick)
        }

        // Dates: 14th-27th Jan -> Analytics packets for: 13th-26th Jan
        // Isolation is over, but isolation reason still stored for 14 days
        assertOnFieldsForDateRange(dateRange: 14 ... 27) { assertField in
            assertField.isNil(\.hasTestedPositiveBackgroundTick)
        }

        // Current date: 27th Jan -> Analytics packet for: 26th Jan
        // Previous isolation reason no longer stored
        assertAnalyticsPacketIsNormal()
    }

    // this currently happens during an isolation and for the 14 days after isolation
    func testHasTestedPositivePcrBackgroundTickPresentAfterSelfReporting() throws {
        // Current date: 1st Jan
        // Starting state: App running normally, not in isolation
        assertAnalyticsPacketIsNormal()
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan

        // reports positive test result on 2nd Jan
        // Isolation end date: 12th Jan
        selfReportingManager.submit(
            testResult: .positive,
            testKitType: .labResult,
            testDate: $instance.currentDateProvider.currentGregorianDay(timeZone: .utc),
            symptoms: false,
            onsetDay: nil,
            nhsTest: nil,
            reportedResult: nil
        )

        // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
        // Now in isolation due to positive test result
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.receivedPositiveTestResult)
            assertField.equals(expected: 1, \.receivedPositiveTestResultEnteredManually)
            assertField.equals(expected: 0, \.didHaveSymptomsBeforeReceivedTestResult)
            assertField.equals(expected: 0, \.didRememberOnsetSymptomsDateBeforeReceivedTestResult)
            assertField.equals(expected: 0, \.selfReportedPositiveSelfLFDOnGov)
            assertField.equals(expected: 1, \.completedSelfReportingTestFlow)
            assertField.isPresent(\.isIsolatingForTestedPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.equals(expected: 1, \.startedIsolation)
            assertField.isPresent(\.askedToShareExposureKeysInTheInitialFlow)
        }

        // Dates: 4th-13th Jan -> Analytics packets for: 3rd-12th Jan
        // Still in isolation
        assertOnFieldsForDateRange(dateRange: 4 ... 13) { assertField in
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForTestedPositiveBackgroundTick)
            assertField.isNil(\.hasTestedPositiveBackgroundTick)
        }

        // Dates: 14th-27th Jan -> Analytics packets for: 13th-26th Jan
        // Isolation is over, but isolation reason still stored for 14 days
        assertOnFieldsForDateRange(dateRange: 14 ... 27) { assertField in
            assertField.isNil(\.hasTestedPositiveBackgroundTick)
        }

        // Current date: 27th Jan -> Analytics packet for: 26th Jan
        // Previous isolation reason no longer stored
        assertAnalyticsPacketIsNormal()
    }

    func testReportedNegativeTestResult() throws {
        selfReportingManager.recordNegativeTestResultMetrics()

        assertOnFields { assertField in
            assertField.equals(expected: 1, \.selfReportedNegativeSelfLFDTestResultEnteredManually)
            assertField.equals(expected: 0, \.selfReportedVoidSelfLFDTestResultEnteredManually)
            assertField.equals(expected: 0, \.completedSelfReportingTestFlow)
        }

        assertAnalyticsPacketIsNormal()
    }

    func testReportedVoidTestResult() throws {
        selfReportingManager.recordVoidTestResultMetrics()

        assertOnFields { assertField in
            assertField.equals(expected: 0, \.selfReportedNegativeSelfLFDTestResultEnteredManually)
            assertField.equals(expected: 1, \.selfReportedVoidSelfLFDTestResultEnteredManually)
            assertField.equals(expected: 0, \.completedSelfReportingTestFlow)
        }

        assertAnalyticsPacketIsNormal()
    }

    func testConsentedToSharingKeys() {
        assertAnalyticsPacketIsNormal()

        selfReportingManager.submit(
            testResult: .positive,
            testKitType: .labResult,
            testDate: $instance.currentDateProvider.currentGregorianDay(timeZone: .utc),
            symptoms: false,
            onsetDay: nil,
            nhsTest: nil,
            reportedResult: nil
        )

        let keys: [ENTemporaryExposureKey] = []
        selfReportingManager.share(keys: .success(keys), completion: { _ in })

        assertOnFields { assertField in
            assertField.equals(expected: 1, \.consentedToShareExposureKeysInTheInitialFlow)
            assertField.equals(expected: 1, \.successfullySharedExposureKeys)
            assertField.equals(expected: 1, \.receivedPositiveTestResult)
            assertField.equals(expected: 1, \.receivedPositiveTestResultEnteredManually)
            assertField.equals(expected: 1, \.completedSelfReportingTestFlow)
            assertField.equals(expected: 1, \.startedIsolation)
            assertField.isPresent(\.isIsolatingForTestedPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.askedToShareExposureKeysInTheInitialFlow)
        }
    }

    func testDidNotConsentToSharingKeys() {
        assertAnalyticsPacketIsNormal()

        selfReportingManager.submit(
            testResult: .positive,
            testKitType: .labResult,
            testDate: $instance.currentDateProvider.currentGregorianDay(timeZone: .utc),
            symptoms: false,
            onsetDay: nil,
            nhsTest: nil,
            reportedResult: nil
        )

        selfReportingManager.share(keys: .failure(ENError(.notAuthorized)), completion: { _ in })

        assertOnFields { assertField in
            assertField.equals(expected: 0, \.consentedToShareExposureKeysInTheInitialFlow)
            assertField.equals(expected: 0, \.successfullySharedExposureKeys)
            assertField.equals(expected: 1, \.receivedPositiveTestResult)
            assertField.equals(expected: 1, \.receivedPositiveTestResultEnteredManually)
            assertField.equals(expected: 1, \.completedSelfReportingTestFlow)
            assertField.equals(expected: 1, \.startedIsolation)
            assertField.isPresent(\.isIsolatingForTestedPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.askedToShareExposureKeysInTheInitialFlow)
        }
    }
}
