//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import Logging

struct MetricsInfo {
    var payload: MetricsInfoPayload
    var postalDistrict: String
    var localAuthority: String?
    var recordedMetrics: [Metric: Int]
}

enum MetricsInfoPayload {
    case triggeredPayload(TriggeredPayload)
}

struct TriggeredPayload {
    var startDate: Date
    var endDate: Date
    var deviceModel: String
    var operatingSystemVersion: String
    var latestApplicationVersion: String
    var includesMultipleApplicationVersions: Bool
}

struct MetricSubmissionEndpoint: HTTPEndpoint {
    
    private static let logger = Logger(label: "Metrics")
    
    func request(for info: MetricsInfo) throws -> HTTPRequest {
        let payload = SubmissionPayload(info)
        Self.logger.info("Submitting metrics", metadata: .describing(payload))
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(payload)
        return .post("/submission/mobile-analytics", body: .json(data))
    }
    
    func parse(_ response: HTTPResponse) throws {}
    
}

private struct SubmissionPayload: Codable {
    struct Period: Codable {
        var startDate: Date
        var endDate: Date
    }
    
    struct Metadata: Codable {
        var postalDistrict: String
        var localAuthority: String?
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
        var receivedRiskyContactNotification = 0
        var startedIsolation = 0
        var acknowledgedStartOfIsolationDueToRiskyContact = 0
        
        var totalExposureWindowsNotConsideredRisky = 0
        var totalExposureWindowsConsideredRisky = 0
        var totalRiskyContactReminderNotifications = 0
        
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
        var isIsolatingForUnconfirmedTestBackgroundTick = 0
        var hasSelfDiagnosedPositiveBackgroundTick = 0
        var encounterDetectionPausedBackgroundTick = 0
        var hasRiskyContactNotificationsEnabledBackgroundTick = 0
        
        // Isolation payment
        var receivedActiveIpcToken = 0
        var selectedIsolationPaymentsButton = 0
        var launchedIsolationPaymentsApplication = 0
        var haveActiveIpcTokenBackgroundTick = 0
        
        var receivedPositiveLFDTestResultViaPolling = 0
        var receivedNegativeLFDTestResultViaPolling = 0
        var receivedVoidLFDTestResultViaPolling = 0
        var receivedPositiveLFDTestResultEnteredManually = 0
        var receivedNegativeLFDTestResultEnteredManually = 0
        var receivedVoidLFDTestResultEnteredManually = 0
        var receivedUnconfirmedPositiveTestResult = 0
        
        var hasTestedLFDPositiveBackgroundTick = 0
        var isIsolatingForTestedLFDPositiveBackgroundTick = 0
        
        var launchedTestOrdering = 0
        
        var didAskForSymptomsOnPositiveTestEntry = 0
        var didHaveSymptomsBeforeReceivedTestResult = 0
        var didRememberOnsetSymptomsDateBeforeReceivedTestResult = 0
        
        var declaredNegativeResultFromDCT = 0
    }
    
    var includesMultipleApplicationVersions: Bool
    var analyticsWindow: Period
    var metadata: Metadata
    var metrics: Metrics
    
    init(_ metricsInfo: MetricsInfo) {
        switch metricsInfo.payload {
        case .triggeredPayload(let payload):
            analyticsWindow = Period(
                startDate: payload.startDate,
                endDate: payload.endDate
            )
            
            metadata = Metadata(
                postalDistrict: metricsInfo.postalDistrict,
                localAuthority: metricsInfo.localAuthority,
                deviceModel: payload.deviceModel,
                operatingSystemVersion: payload.operatingSystemVersion,
                latestApplicationVersion: payload.latestApplicationVersion
            )
            
            includesMultipleApplicationVersions = payload.includesMultipleApplicationVersions
            
            metrics = mutating(Metrics()) {
                $0.cumulativeWifiUploadBytes = 0
                $0.cumulativeWifiDownloadBytes = 0
                $0.cumulativeCellularUploadBytes = 0
                $0.cumulativeCellularDownloadBytes = 0
                $0.cumulativeDownloadBytes = 0
                $0.cumulativeUploadBytes = 0
                
                for metric in Metric.allCases {
                    $0[keyPath: metric.property] = metricsInfo.recordedMetrics[metric] ?? 0
                }
            }
        }
    }
}

private extension Measurement where UnitType: Dimension {
    
    func value(in unit: UnitType) -> Double {
        converted(to: unit).value
    }
    
}

private extension Metric {
    
    var property: WritableKeyPath<SubmissionPayload.Metrics, Int> {
        switch self {
        case .backgroundTasks: return \.totalBackgroundTasks
        case .completedOnboarding: return \.completedOnboarding
        case .checkedIn: return \.checkedIn
        case .deletedLastCheckIn: return \.canceledCheckIn
        case .completedQuestionnaireAndStartedIsolation: return \.completedQuestionnaireAndStartedIsolation
        case .completedQuestionnaireButDidNotStartIsolation: return \.completedQuestionnaireButDidNotStartIsolation
        case .receivedPositiveTestResult: return \.receivedPositiveTestResult
        case .receivedNegativeTestResult: return \.receivedNegativeTestResult
        case .receivedVoidTestResult: return \.receivedVoidTestResult
        case .contactCaseBackgroundTick: return \.hasHadRiskyContactBackgroundTick
        case .selfDiagnosedBackgroundTick: return \.hasSelfDiagnosedBackgroundTick
        case .testedPositiveBackgroundTick: return \.hasTestedPositiveBackgroundTick
        case .isolatedForSelfDiagnosedBackgroundTick: return \.isIsolatingForSelfDiagnosedBackgroundTick
        case .isolatedForTestedPositiveBackgroundTick: return \.isIsolatingForTestedPositiveBackgroundTick
        case .isolatedForHadRiskyContactBackgroundTick: return \.isIsolatingForHadRiskyContactBackgroundTick
        case .isolatedForUnconfirmedTestBackgroundTick: return \.isIsolatingForUnconfirmedTestBackgroundTick
        case .indexCaseBackgroundTick: return \.hasSelfDiagnosedPositiveBackgroundTick
        case .isolationBackgroundTick: return \.isIsolatingBackgroundTick
        case .pauseTick: return \.encounterDetectionPausedBackgroundTick
        case .runningNormallyTick: return \.runningNormallyBackgroundTick
        case .receivedVoidTestResultEnteredManually: return \.receivedVoidTestResultEnteredManually
        case .receivedPositiveTestResultEnteredManually: return \.receivedPositiveTestResultEnteredManually
        case .receivedNegativeTestResultEnteredManually: return \.receivedNegativeTestResultEnteredManually
        case .receivedVoidTestResultViaPolling: return \.receivedVoidTestResultViaPolling
        case .receivedPositiveTestResultViaPolling: return \.receivedPositiveTestResultViaPolling
        case .receivedNegativeTestResultViaPolling: return \.receivedNegativeTestResultViaPolling
        case .receivedRiskyContactNotification: return \.receivedRiskyContactNotification
        case .startedIsolation: return \.startedIsolation
        case .receivedActiveIpcToken: return \.receivedActiveIpcToken
        case .haveActiveIpcTokenBackgroundTick: return \.haveActiveIpcTokenBackgroundTick
        case .selectedIsolationPaymentsButton: return \.selectedIsolationPaymentsButton
        case .launchedIsolationPaymentsApplication: return \.launchedIsolationPaymentsApplication
        case .totalExposureWindowsNotConsideredRisky: return \.totalExposureWindowsNotConsideredRisky
        case .totalExposureWindowsConsideredRisky: return \.totalExposureWindowsConsideredRisky
        case .receivedPositiveLFDTestResultViaPolling: return \.receivedPositiveLFDTestResultViaPolling
        case .receivedNegativeLFDTestResultViaPolling: return \.receivedNegativeLFDTestResultViaPolling
        case .receivedVoidLFDTestResultViaPolling: return \.receivedVoidLFDTestResultViaPolling
        case .receivedPositiveLFDTestResultEnteredManually: return \.receivedPositiveLFDTestResultEnteredManually
        case .receivedNegativeLFDTestResultEnteredManually: return \.receivedNegativeLFDTestResultEnteredManually
        case .receivedVoidLFDTestResultEnteredManually: return \.receivedVoidLFDTestResultEnteredManually
        case .receivedUnconfirmedPositiveTestResult: return \.receivedUnconfirmedPositiveTestResult
        case .hasTestedLFDPositiveBackgroundTick: return \.hasTestedLFDPositiveBackgroundTick
        case .isIsolatingForTestedLFDPositiveBackgroundTick: return \.isIsolatingForTestedLFDPositiveBackgroundTick
        case .acknowledgedStartOfIsolationDueToRiskyContact: return \.acknowledgedStartOfIsolationDueToRiskyContact
        case .hasRiskyContactNotificationsEnabledBackgroundTick: return \.hasRiskyContactNotificationsEnabledBackgroundTick
        case .totalRiskyContactReminderNotifications: return \.totalRiskyContactReminderNotifications
        case .launchedTestOrdering: return \.launchedTestOrdering
        case .didAskForSymptomsOnPositiveTestEntry: return \.didAskForSymptomsOnPositiveTestEntry
        case .didHaveSymptomsBeforeReceivedTestResult: return \.didHaveSymptomsBeforeReceivedTestResult
        case .didRememberOnsetSymptomsDateBeforeReceivedTestResult: return \.didRememberOnsetSymptomsDateBeforeReceivedTestResult
        case .declaredNegativeResultFromDCT: return \.declaredNegativeResultFromDCT
        }
    }
    
}
