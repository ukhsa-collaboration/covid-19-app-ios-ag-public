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
            } catch {}
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
    enum MetricField: Decodable, Equatable, ExpressibleByIntegerLiteral {
        case exact(value: Int)
        case notZero
        case lessThanTotalBackgroundTasks
        
        init(from decoder: Decoder) throws {
            self = .exact(value: try decoder.singleValueContainer().decode(Int.self))
        }
        
        var value: Int {
            switch self {
            case .exact(let value):
                return value
            case .notZero, .lessThanTotalBackgroundTasks:
                // Ideally, we'd structure our types so that values decoded would not be representable with these cases
                // (see our implementation of `init(from: Decoder)`).
                //
                // For now, we know that to be the case, so assert that a value exists if we ask for it.
                preconditionFailure("We should never be in a scenario where this is used.")
            }
        }
        
        init(integerLiteral value: Int) {
            self = .exact(value: value)
        }
    }
    
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
        var cumulativeWifiUploadBytes: MetricField = 0
        var cumulativeWifiDownloadBytes: MetricField = 0
        var cumulativeCellularUploadBytes: MetricField = 0
        var cumulativeCellularDownloadBytes: MetricField = 0
        var cumulativeDownloadBytes: MetricField = 0
        var cumulativeUploadBytes: MetricField = 0
        
        // Events triggered
        var completedOnboarding: MetricField = 0
        var checkedIn: MetricField = 0
        var canceledCheckIn: MetricField = 0
        var completedQuestionnaireAndStartedIsolation: MetricField = 0
        var completedQuestionnaireButDidNotStartIsolation: MetricField = 0
        var receivedPositiveTestResult: MetricField = 0
        var receivedNegativeTestResult: MetricField = 0
        var receivedVoidTestResult: MetricField = 0
        var receivedVoidTestResultEnteredManually: MetricField = 0
        var receivedPositiveTestResultEnteredManually: MetricField = 0
        var receivedNegativeTestResultEnteredManually: MetricField = 0
        var receivedVoidTestResultViaPolling: MetricField = 0
        var receivedPositiveTestResultViaPolling: MetricField = 0
        var receivedNegativeTestResultViaPolling: MetricField = 0
        var receivedRiskyContactNotification: MetricField = 0
        var receivedUnconfirmedPositiveTestResult: MetricField = 0
        var startedIsolation: MetricField = 0
        
        // How many times background tasks ran
        var totalBackgroundTasks: MetricField = 0
        
        // How many times background tasks ran when app was running normally (max: totalBackgroundTasks)
        var runningNormallyBackgroundTick: MetricField = 0
        
        // Background ticks (max: runningNormallyBackgroundTick)
        var isIsolatingBackgroundTick: MetricField = 0
        var hasHadRiskyContactBackgroundTick: MetricField = 0
        var hasSelfDiagnosedBackgroundTick: MetricField = 0
        var hasTestedPositiveBackgroundTick: MetricField = 0
        var isIsolatingForSelfDiagnosedBackgroundTick: MetricField = 0
        var isIsolatingForTestedPositiveBackgroundTick: MetricField = 0
        var isIsolatingForHadRiskyContactBackgroundTick: MetricField = 0
        var isIsolatingForUnconfirmedTestBackgroundTick: MetricField = 0
        var hasSelfDiagnosedPositiveBackgroundTick: MetricField = 0
        var encounterDetectionPausedBackgroundTick: MetricField = 0
        
        var receivedActiveIpcToken: MetricField = 0
        var selectedIsolationPaymentsButton: MetricField = 0
        var launchedIsolationPaymentsApplication: MetricField = 0
        var haveActiveIpcTokenBackgroundTick: MetricField = 0
        
        var didAskForSymptomsOnPositiveTestEntry: MetricField = 0
        var didHaveSymptomsBeforeReceivedTestResult: MetricField = 0
        var didRememberOnsetSymptomsDateBeforeReceivedTestResult: MetricField = 0
        
        var receivedPositiveSelfRapidTestResultEnteredManually: MetricField = 0
        var isIsolatingForTestedSelfRapidPositiveBackgroundTick: MetricField = 0
        var hasTestedSelfRapidPositiveBackgroundTick: MetricField = 0
        
        var optedOutForContactIsolation: MetricField = 0
        var optedOutForContactIsolationBackgroundTick: MetricField = 0
        
        var appIsUsableBackgroundTick: MetricField = 0
        var appIsUsableBluetoothOffBackgroundTick: MetricField = 0
        var appIsContactTraceableBackgroundTick: MetricField = 0
    }
    
    var includesMultipleApplicationVersions: Bool
    var analyticsWindow: Period
    var metadata: Metadata
    var metrics: Metrics
}

extension SubmissionPayload.MetricField: CustomDescriptionConvertible {
    
    var descriptionObject: Description {
        switch self {
        case .exact(let value):
            return .string("\(value)")
        case .notZero:
            return .string("not-zero")
        case .lessThanTotalBackgroundTasks:
            return .string("less-than-totalBackgroundTasks")
        }
    }
    
}
