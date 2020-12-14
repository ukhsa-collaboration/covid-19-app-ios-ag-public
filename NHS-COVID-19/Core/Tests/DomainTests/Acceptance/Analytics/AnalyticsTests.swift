//
// Copyright © 2020 NHSX. All rights reserved.
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
        $instance.exposureNotificationManager = MockWindowsExposureNotificationManager()
        metricsPayloads = []
        currentDateProvider.setDate(startDate)
        subscribeToMetricsRequests()
        try! completeRunning()
        setUpFunctionalities()
    }
    
    func setUpFunctionalities() {
    }
    
    override func tearDown() {
        apiClient.reset()
        distributeClient.reset()
    }
}

// MARK: Helpers

@available(iOS 13.7, *)
extension AnalyticsTests {
    func advanceToEndOfAnalyticsWindow(steps: Int = 12) {
        currentDateProvider.advanceToEndOfAnalyticsWindow(
            steps: steps,
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
}

// MARK: Assertion

@available(iOS 13.7, *)
extension AnalyticsTests {
    struct Assertion {
        private let value: Int
        private let totalBackgroundTasks: Int
        
        init(value: Int, totalBackgroundTasks: Int) {
            self.value = value
            self.totalBackgroundTasks = totalBackgroundTasks
        }
        
        func equals(_ expectedValue: Int) {
            XCTAssertEqual(value, expectedValue)
        }
        
        func isPresent() {
            XCTAssert(value > 0)
        }
        
        func isLessThanTotalBackgroundTasks() {
            XCTAssert(value < totalBackgroundTasks)
        }
        
        func isNotPresent() {
            equals(0)
        }
    }
    
    func assert(_ keyPath: KeyPath<SubmissionPayload.Metrics, Int>) -> Assertion {
        Assertion(
            value: lastMetricsPayload!.metrics[keyPath: keyPath],
            totalBackgroundTasks: lastMetricsPayload!.metrics.totalBackgroundTasks
        )
    }
}

// MARK: Model

// Copy of SubmissionPayload from MetricSubmissionEndpoint.swift
struct SubmissionPayload: Codable {
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
    
    struct Metrics: Codable {
        // Networking
        var cumulativeWifiUploadBytes = 0
        var cumulativeWifiDownloadBytes = 0
        var cumulativeCellularUploadBytes = 0
        var cumulativeCellularDownloadBytes = 0
        var cumulativeDownloadBytes = 0
        var cumulativeUploadBytes = 0
        
        // Events triggered
        var completedOnboarding = 0
        var checkedIn = 0
        var canceledCheckIn = 0
        var completedQuestionnaireAndStartedIsolation = 0
        var completedQuestionnaireButDidNotStartIsolation = 0
        var receivedPositiveTestResult = 0
        var receivedNegativeTestResult = 0
        var receivedVoidTestResult = 0
        var receivedVoidTestResultEnteredManually = 0
        var receivedPositiveTestResultEnteredManually = 0
        var receivedNegativeTestResultEnteredManually = 0
        var receivedVoidTestResultViaPolling = 0
        var receivedPositiveTestResultViaPolling = 0
        var receivedNegativeTestResultViaPolling = 0
        
        // How many times background tasks ran
        var totalBackgroundTasks = 0
        
        // How many times background tasks ran when app was running normally (max: totalBackgroundTasks)
        var runningNormallyBackgroundTick = 0
        
        // Background ticks (max: runningNormallyBackgroundTick)
        var isIsolatingBackgroundTick = 0
        var hasHadRiskyContactBackgroundTick = 0
        var hasSelfDiagnosedBackgroundTick = 0
        var hasTestedPositiveBackgroundTick = 0
        var isIsolatingForSelfDiagnosedBackgroundTick = 0
        var isIsolatingForTestedPositiveBackgroundTick = 0
        var isIsolatingForHadRiskyContactBackgroundTick = 0
        var hasSelfDiagnosedPositiveBackgroundTick = 0
        var encounterDetectionPausedBackgroundTick = 0
    }
    
    var includesMultipleApplicationVersions: Bool
    var analyticsWindow: Period
    var metadata: Metadata
    var metrics: Metrics
}
