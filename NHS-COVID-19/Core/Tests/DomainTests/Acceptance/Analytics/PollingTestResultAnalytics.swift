//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class PollingTestResultAnalyticsTests: AnalyticsTests {
    private var pollingTestResult: PollingTestResult!
    private var testOrdering: TestOrdering!
    private var questionnaire: Questionnaire!

    override func setUpFunctionalities() {
        let runningAppContext = try! context()
        pollingTestResult = PollingTestResult(configuration: $instance, context: runningAppContext)
        testOrdering = TestOrdering(configuration: $instance, context: runningAppContext)
        questionnaire = Questionnaire(context: runningAppContext)
    }

    // hasTestedPositiveBackgroundTick - Polling
    // >0 if the app is aware that the user has received/entered a positive test
    // this currently happens during an isolation and for the 14 days after isolation
    func testHasTestedPositiveBackgroundTickPresentAfterTestResultReceived() throws {
        // Current date: 1st Jan
        // Starting state: App running normally, not in isolation
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        assertAnalyticsPacketIsNormal()

        // Complete questionnaire with risky symptoms and order test on 2nd Jan
        // Symptom onset date: 2nd Jan
        // Isolation end date: 12th Jan
        try questionnaire.selfDiagnosePositive(onsetDay: currentDateProvider.currentGregorianDay(timeZone: .utc))
        try testOrdering.order()

        // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
        // Now in isolation due to self-diagnosis
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.startedIsolation)
            assertField.isNil(\.completedQuestionnaireAndStartedIsolation)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
        }

        // Receive positive test result via polling
        try pollingTestResult.receivePositiveAndAcknowledge {
            self.advanceToNextBackgroundTaskExecution()
        }

        // Current date: 4th Jan -> Analytics packet for: 3rd Jan
        // Still in isolation, for both self-diagnosis and positive test result
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.receivedPositiveTestResult)
            assertField.equals(expected: 1, \.receivedPositiveTestResultViaPolling)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.hasTestedPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.isIsolatingForTestedPositiveBackgroundTick)
            assertField.isPresent(\.askedToShareExposureKeysInTheInitialFlow)
        }

        // Dates: 5th-13th Jan -> Analytics packets for: 4th-13th Jan
        // Still in isolation
        assertOnFieldsForDateRange(dateRange: 5 ... 13) { assertField in
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForTestedPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.hasTestedPositiveBackgroundTick)
        }

        // Dates: 14th-27th Jan -> Analytics packets for: 13th-26th Jan
        // Isolation is over, but isolation reason still stored for 14 days
        assertOnFieldsForDateRange(dateRange: 14 ... 27) { assertField in
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.hasTestedPositiveBackgroundTick)
        }

        // Current date: 28th Jan -> Analytics packet for: 27th Jan
        // Previous isolation reason no longer stored
        assertAnalyticsPacketIsNormal()
    }

    func testReceivingNegativeTestResultAfterPositiveSelfDiagnosisEndsIsolation() throws {
        // Current date: 1st Jan
        // Starting state: App running normally, not in isolation
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        assertAnalyticsPacketIsNormal()

        // Complete questionnaire with risky symptoms and order test on 2nd Jan
        // Symptom onset date: 2nd Jan
        // Isolation end date: 12th Jan
        try questionnaire.selfDiagnosePositive(onsetDay: currentDateProvider.currentGregorianDay(timeZone: .utc))
        try testOrdering.order()

        // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
        // Now in isolation due to self-diagnosis
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.startedIsolation)
            assertField.isNil(\.completedQuestionnaireAndStartedIsolation)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
        }

        // Receive negative test result via polling
        try pollingTestResult.receiveNegativeAndAcknowledge {
            self.advanceToNextBackgroundTaskExecution()
        }

        // Current date: 4th Jan -> Analytics packet for: 3rd Jan
        // Isolation ends part way through analytics window due to negative test result
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.receivedNegativeTestResult)
            assertField.equals(expected: 1, \.receivedNegativeTestResultViaPolling)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
            assertField.isLessThanTotalBackgroundTasks(\.isIsolatingBackgroundTick)
            assertField.isLessThanTotalBackgroundTasks(\.isIsolatingForSelfDiagnosedBackgroundTick)
        }

        // Reason stored until 17th
        // Dates: 5th-17th Jan -> Analytics packets for: 4th-16th Jan
        // Isolation is over, but isolation reason still stored for 14 days
        assertOnFieldsForDateRange(dateRange: 5 ... 17) { assertField in
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
        }

        assertAnalyticsPacketIsNormal()
    }

    func testReceivingVoidTestResultAfterPositiveSelfDiagnosis() throws {
        // Complete questionnaire with risky symptoms and order test on 1st Jan
        // Symptom onset date: 1st Jan
        // Isolation end date: 11th Jan
        try questionnaire.selfDiagnosePositive(onsetDay: currentDateProvider.currentGregorianDay(timeZone: .utc))
        try testOrdering.order()

        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        // Now in isolation due to self-diagnosis
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.startedIsolation)
            assertField.isNil(\.completedQuestionnaireAndStartedIsolation)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
        }

        // Receive negative test result via polling
        try pollingTestResult.receiveVoidAndAcknowledge {
            self.advanceToNextBackgroundTaskExecution()
        }

        assertOnFields { assertFields in
            // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
            assertFields.isPresent(\.receivedVoidTestResult)
            assertFields.isPresent(\.receivedVoidTestResultViaPolling)

            // Still isolating
            assertFields.isPresent(\.hasSelfDiagnosedBackgroundTick)
            assertFields.isPresent(\.isIsolatingBackgroundTick)
            assertFields.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
        }
    }

    func testReceivingPositiveSelfRapidTestResult() throws {
        assertAnalyticsPacketIsNormal()

        // Fill questionnaire and order a test
        try questionnaire.selfDiagnosePositive(onsetDay: currentDateProvider.currentGregorianDay(timeZone: .utc))
        try testOrdering.order()

        // Receive rapid-self-reported positive test result via polling
        try pollingTestResult.receivePositiveAndAcknowledge(testKitType: .rapidSelfReported) {
            self.advanceToNextBackgroundTaskExecution()
        }

        // The day of entering the test result
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.startedIsolation)
            assertField.isNil(\.completedQuestionnaireAndStartedIsolation)

            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.isIsolatingForTestedSelfRapidPositiveBackgroundTick)

            assertField.equals(expected: 1, \.receivedPositiveTestResult)

            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.hasTestedSelfRapidPositiveBackgroundTick)

            assertField.isPresent(\.askedToShareExposureKeysInTheInitialFlow)
        }

        // As long as the user is in isolation
        assertOnFieldsForDateRange(dateRange: 4 ... 13) { assertField in
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForTestedSelfRapidPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)

            assertField.isPresent(\.hasTestedSelfRapidPositiveBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
        }

        // 14 Days after isolation - data retention
        assertOnFieldsForDateRange(dateRange: 14 ... 27) { assertField in
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.hasTestedSelfRapidPositiveBackgroundTick)
        }

        assertAnalyticsPacketIsNormal()
    }
}
