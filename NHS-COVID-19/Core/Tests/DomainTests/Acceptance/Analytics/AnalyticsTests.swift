//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import TestSupport
import XCTest
@testable import Domain
@testable import Integration
@testable import Scenarios

@available(iOS 13.7, *)
class AnalyticsTests: AcceptanceTestCase {
    private var cancellables = [AnyCancellable]()
    private var metricsPayloads: [SubmissionPayload] = []

    private let startDate = GregorianDay(year: 2020, month: 1, day: 1).startDate(in: .utc)

    override final func setUp() {
        continueAfterFailure = false
        $instance.exposureNotificationManager = MockWindowsExposureNotificationManager()
        metricsPayloads = []
        currentDateProvider.setDate(startDate)
        subscribeToMetricsRequests()
        try! completeRunning()
        setUpFunctionalities()
    }

    func setUpFunctionalities() {}

    override func tearDown() {
        apiClient.reset()
        distributeClient.reset()
    }
}

// MARK: Helpers

@available(iOS 13.7, *)
extension AnalyticsTests {
    private func advanceToEndOfAnalyticsWindow() {
        currentDateProvider.advanceToEndOfAnalyticsWindow(
            steps: 12,
            performBackgroundTask: performBackgroundTask
        )
    }

    func advanceToNextBackgroundTaskExecution() {
        currentDateProvider.advanceToNextBackgroundTaskExecution(performBackgroundTask: performBackgroundTask)
    }

    private func performBackgroundTask() {
        coordinator.performBackgroundTask(task: NoOpBackgroundTask())
    }

    var lastMetricsPayload: SubmissionPayload? {
        metricsPayloads.last
    }

    func subscribeToMetricsRequests() {
        apiClient.$lastRequest.sink { request in
            guard let request = request,
                let body = request.body,
                request.path == "/submission/mobile-analytics" else {
                return
            }

            let decoder = JSONDecoder()
            do {
                let metricsPayload = try decoder.decode(SubmissionPayload.self, from: body.content)
                self.metricsPayloads.append(metricsPayload)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        .store(in: &cancellables)
    }

    func assertOnFields(assertions: (inout FieldAsserter) -> Void) {
        advanceToEndOfAnalyticsWindow()
        assertOnLastPacket(assertions: assertions)
    }

    func assertOnFieldsForDateRange(dateRange: ClosedRange<Int>, assertions: (inout FieldAsserter) -> Void) {
        for day in dateRange {
            advanceToEndOfAnalyticsWindow()
            assertOnLastPacket(assertions: assertions, day: day)
        }
    }

    func assertOnLastFields(assertions: (inout FieldAsserter) -> Void) {
        assertOnLastPacket(assertions: assertions)
    }

    private func assertOnLastPacket(assertions: (inout FieldAsserter) -> Void, day: Int? = nil) {
        var fieldAsserter = FieldAsserter()
        assertions(&fieldAsserter)
        fieldAsserter.runAllAssertions(metrics: lastMetricsPayload!.metrics, day: day)
    }

    func assertAnalyticsPacketIsNormal() {
        advanceToEndOfAnalyticsWindow()
        FieldAsserter().runAllAssertions(metrics: lastMetricsPayload!.metrics)
    }
}

// MARK: Model

// Copy of SubmissionPayload from MetricSubmissionEndpoint.swift
struct SubmissionPayload: Decodable {

    struct Period: Codable {
        var startDate: String
        var endDate: String
    }

    struct Metadata: Codable {
        var postalDistrict: String
        var deviceModel: String
        var operatingSystemVersion: String
        var latestApplicationVersion: String
    }

    struct Metrics: Decodable, Equatable {
        // Networking
        var cumulativeWifiUploadBytes: Int? = 0
        var cumulativeWifiDownloadBytes: Int? = 0
        var cumulativeCellularUploadBytes: Int? = 0
        var cumulativeCellularDownloadBytes: Int? = 0
        var cumulativeDownloadBytes: Int? = 0
        var cumulativeUploadBytes: Int? = 0

        // Events triggered
        var completedOnboarding: Int? = 0
        var checkedIn: Int? = 0
        var canceledCheckIn: Int? = 0
        var completedQuestionnaireAndStartedIsolation: Int? = nil
        var receivedPositiveTestResult: Int? = 0
        var receivedNegativeTestResult: Int? = 0
        var receivedVoidTestResult: Int? = 0
        var receivedVoidTestResultEnteredManually: Int? = 0
        var receivedPositiveTestResultEnteredManually: Int? = 0
        var receivedNegativeTestResultEnteredManually: Int? = 0
        var receivedVoidTestResultViaPolling: Int? = 0
        var receivedPositiveTestResultViaPolling: Int? = 0
        var receivedNegativeTestResultViaPolling: Int? = 0
        var receivedRiskyContactNotification: Int? = 0
        var startedIsolation: Int? = 0
        var acknowledgedStartOfIsolationDueToRiskyContact: Int? = 0

        var totalExposureWindowsNotConsideredRisky: Int? = 0

        // How many times background tasks ran
        var totalBackgroundTasks: Int? = 0

        // How many times background tasks ran when app was running normally (max: totalBackgroundTasks)
        var runningNormallyBackgroundTick: Int? = 0

        // Background ticks (max: runningNormallyBackgroundTick)
        var isIsolatingBackgroundTick: Int? = 0
        var hasHadRiskyContactBackgroundTick: Int? = 0
        var hasSelfDiagnosedBackgroundTick: Int? = nil
        var hasTestedPositiveBackgroundTick: Int? = nil
        var isIsolatingForSelfDiagnosedBackgroundTick: Int? = nil
        var isIsolatingForTestedPositiveBackgroundTick: Int? = 0
        var isIsolatingForHadRiskyContactBackgroundTick: Int? = 0
        var isIsolatingForUnconfirmedTestBackgroundTick: Int? = 0
        var encounterDetectionPausedBackgroundTick: Int? = 0
        var hasRiskyContactNotificationsEnabledBackgroundTick: Int? = 0

        // Isolation payment
        var receivedActiveIpcToken: Int? = 0
        var selectedIsolationPaymentsButton: Int? = 0
        var launchedIsolationPaymentsApplication: Int? = 0
        var haveActiveIpcTokenBackgroundTick: Int? = 0

        var receivedPositiveLFDTestResultEnteredManually: Int? = 0

        var receivedUnconfirmedPositiveTestResult: Int? = 0

        var receivedPositiveSelfRapidTestResultEnteredManually: Int? = 0
        var isIsolatingForTestedSelfRapidPositiveBackgroundTick: Int? = 0
        var hasTestedSelfRapidPositiveBackgroundTick: Int? = nil

        var hasTestedLFDPositiveBackgroundTick: Int? = nil
        var isIsolatingForTestedLFDPositiveBackgroundTick: Int? = 0

        var launchedTestOrdering: Int? = 0

        var didAskForSymptomsOnPositiveTestEntry: Int? = nil
        var didHaveSymptomsBeforeReceivedTestResult: Int? = 0
        var didRememberOnsetSymptomsDateBeforeReceivedTestResult: Int? = 0

        var didAccessSelfIsolationNoteLink: Int? = 0

        // MARK: - Risky venue warning

        var receivedRiskyVenueM1Warning: Int? = 0
        var receivedRiskyVenueM2Warning: Int? = 0 //
        var hasReceivedRiskyVenueM2WarningBackgroundTick: Int? = 0
        var didAccessRiskyVenueM2Notification: Int? = 0
        var selectedTakeTestM2Journey: Int? = 0
        var selectedTakeTestLaterM2Journey: Int? = 0
        var selectedHasSymptomsM2Journey: Int? = 0
        var selectedHasNoSymptomsM2Journey: Int? = 0
        var selectedLFDTestOrderingM2Journey: Int? = 0
        var selectedHasLFDTestM2Journey: Int? = 0

        // MARK: Key Sharing

        var askedToShareExposureKeysInTheInitialFlow: Int? = 0
        var consentedToShareExposureKeysInTheInitialFlow: Int? = 0
        var totalShareExposureKeysReminderNotifications: Int? = 0
        var consentedToShareExposureKeysInReminderScreen: Int? = 0
        var successfullySharedExposureKeys: Int? = 0

        // MARK: - Local Information / VOC

        var didSendLocalInfoNotification: Int? = 0
        var didAccessLocalInfoScreenViaNotification: Int? = 0
        var didAccessLocalInfoScreenViaBanner: Int? = 0
        var isDisplayingLocalInfoBackgroundTick: Int? = 0

        // MARK: - Lab test result after rapid result

        var positiveLabResultAfterPositiveLFD: Int? = 0
        var negativeLabResultAfterPositiveLFDWithinTimeLimit: Int? = 0
        var negativeLabResultAfterPositiveLFDOutsideTimeLimit: Int? = 0
        var positiveLabResultAfterPositiveSelfRapidTest: Int? = 0
        var negativeLabResultAfterPositiveSelfRapidTestWithinTimeLimit: Int? = 0
        var negativeLabResultAfterPositiveSelfRapidTestOutsideTimeLimit: Int? = 0

        // MARK: - Contact case opt-out

        var optedOutForContactIsolation: Int? = 0
        var optedOutForContactIsolationBackgroundTick: Int? = 0

        // MARK: - New app state metrics

        var appIsUsableBackgroundTick: Int? = 0
        var appIsUsableBluetoothOffBackgroundTick: Int? = 0
        var appIsContactTraceableBackgroundTick: Int? = 0

        var completedV2SymptomsQuestionnaire: Int? = 0
        var completedV2SymptomsQuestionnaireAndStayAtHome: Int? = 0
        var hasCompletedV2SymptomsQuestionnaireBackgroundTick: Int? = nil
        var hasCompletedV2SymptomsQuestionnaireAndStayAtHomeBackgroundTick: Int? = nil

        var completedV3SymptomsQuestionnaireAndHasSymptoms: Int? = 0

        // MARK: Self reporting
        var selfReportedVoidSelfLFDTestResultEnteredManually: Int? = 0
        var selfReportedNegativeSelfLFDTestResultEnteredManually: Int? = 0
        var isPositiveSelfLFDFree: Int? = 0
        var selfReportedPositiveSelfLFDOnGov: Int? = 0
        var completedSelfReportingTestFlow: Int? = 0
    }

    var includesMultipleApplicationVersions: Bool
    var analyticsWindow: Period
    var metadata: Metadata
    var metrics: Metrics
}
