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
    var excludedMetrics: [Metric]
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
        var completedQuestionnaireAndStartedIsolation: Int? = 0
        var completedQuestionnaireButDidNotStartIsolation: Int? = 0
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
        var totalExposureWindowsConsideredRisky: Int? = 0
        var totalRiskyContactReminderNotifications: Int? = 0
        
        // How many times background tasks ran
        var totalBackgroundTasks: Int? = 0
        
        // How many times background tasks ran when app was running normally (max: totalBackgroundTasks)
        var runningNormallyBackgroundTick: Int? = 0
        
        // Background ticks (max: runningNormallyBackgroundTick)
        var isIsolatingBackgroundTick: Int? = 0
        var hasHadRiskyContactBackgroundTick: Int? = 0
        var hasSelfDiagnosedBackgroundTick: Int? = 0
        var hasTestedPositiveBackgroundTick: Int? = 0
        var isIsolatingForSelfDiagnosedBackgroundTick: Int? = 0
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
        var hasTestedSelfRapidPositiveBackgroundTick: Int? = 0
        
        var hasTestedLFDPositiveBackgroundTick: Int? = 0
        var isIsolatingForTestedLFDPositiveBackgroundTick: Int? = 0
        
        var launchedTestOrdering: Int? = 0
        
        var didAskForSymptomsOnPositiveTestEntry: Int? = 0
        var didHaveSymptomsBeforeReceivedTestResult: Int? = 0
        var didRememberOnsetSymptomsDateBeforeReceivedTestResult: Int? = 0
        
        var didAccessSelfIsolationNoteLink: Int? = 0
        
        // MARK: - Risky venue warning
        
        var receivedRiskyVenueM1Warning: Int? = 0
        var receivedRiskyVenueM2Warning: Int? = 0
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
        var hasCompletedV2SymptomsQuestionnaireBackgroundTick: Int? = 0
        var hasCompletedV2SymptomsQuestionnaireAndStayAtHomeBackgroundTick: Int? = 0
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
                    if metricsInfo.excludedMetrics.contains(metric) {
                        $0[keyPath: metric.property] = nil
                    } else {
                        $0[keyPath: metric.property] = metricsInfo.recordedMetrics[metric] ?? 0
                    }
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
    
    var property: WritableKeyPath<SubmissionPayload.Metrics, Int?> {
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
        case .receivedPositiveLFDTestResultEnteredManually: return \.receivedPositiveLFDTestResultEnteredManually
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
        case .receivedPositiveSelfRapidTestResultEnteredManually: return \.receivedPositiveSelfRapidTestResultEnteredManually
        case .isIsolatingForTestedSelfRapidPositiveBackgroundTick: return \.isIsolatingForTestedSelfRapidPositiveBackgroundTick
        case .hasTestedSelfRapidPositiveBackgroundTick: return \.hasTestedSelfRapidPositiveBackgroundTick
        case .receivedRiskyVenueM1Warning: return \.receivedRiskyVenueM1Warning
        case .receivedRiskyVenueM2Warning: return \.receivedRiskyVenueM2Warning
        case .hasReceivedRiskyVenueM2WarningBackgroundTick: return \.hasReceivedRiskyVenueM2WarningBackgroundTick
        case .askedToShareExposureKeysInTheInitialFlow: return \.askedToShareExposureKeysInTheInitialFlow
        case .consentedToShareExposureKeysInTheInitialFlow: return \.consentedToShareExposureKeysInTheInitialFlow
        case .totalShareExposureKeysReminderNotifications: return \.totalShareExposureKeysReminderNotifications
        case .consentedToShareExposureKeysInReminderScreen: return \.consentedToShareExposureKeysInReminderScreen
        case .successfullySharedExposureKeys: return \.successfullySharedExposureKeys
        case .didSendLocalInfoNotification: return \.didSendLocalInfoNotification
        case .didAccessLocalInfoScreenViaNotification: return \.didAccessLocalInfoScreenViaNotification
        case .didAccessLocalInfoScreenViaBanner: return \.didAccessLocalInfoScreenViaBanner
        case .isDisplayingLocalInfoBackgroundTick: return \.isDisplayingLocalInfoBackgroundTick
        case .positiveLabResultAfterPositiveLFD: return \.positiveLabResultAfterPositiveLFD
        case .negativeLabResultAfterPositiveLFDWithinTimeLimit: return \.negativeLabResultAfterPositiveLFDWithinTimeLimit
        case .negativeLabResultAfterPositiveLFDOutsideTimeLimit: return \.negativeLabResultAfterPositiveLFDOutsideTimeLimit
        case .positiveLabResultAfterPositiveSelfRapidTest: return \.positiveLabResultAfterPositiveSelfRapidTest
        case .negativeLabResultAfterPositiveSelfRapidTestWithinTimeLimit: return \.negativeLabResultAfterPositiveSelfRapidTestWithinTimeLimit
        case .negativeLabResultAfterPositiveSelfRapidTestOutsideTimeLimit: return \.negativeLabResultAfterPositiveSelfRapidTestOutsideTimeLimit
        case .didAccessRiskyVenueM2Notification: return \.didAccessRiskyVenueM2Notification
        case .selectedTakeTestM2Journey: return \.selectedTakeTestM2Journey
        case .selectedTakeTestLaterM2Journey: return \.selectedTakeTestLaterM2Journey
        case .selectedHasSymptomsM2Journey: return \.selectedHasSymptomsM2Journey
        case .selectedHasNoSymptomsM2Journey: return \.selectedHasNoSymptomsM2Journey
        case .selectedLFDTestOrderingM2Journey: return \.selectedLFDTestOrderingM2Journey
        case .selectedHasLFDTestM2Journey: return \.selectedHasLFDTestM2Journey
        case .optedOutForContactIsolation: return \.optedOutForContactIsolation
        case .optedOutForContactIsolationBackgroundTick: return \.optedOutForContactIsolationBackgroundTick
        case .appIsUsableBackgroundTick: return \.appIsUsableBackgroundTick
        case .appIsUsableBluetoothOffBackgroundTick: return \.appIsUsableBluetoothOffBackgroundTick
        case .appIsContactTraceableBackgroundTick: return \.appIsContactTraceableBackgroundTick
        case .didAccessSelfIsolationNoteLink: return \.didAccessSelfIsolationNoteLink
        case .completedV2SymptomsQuestionnaire: return \.completedV2SymptomsQuestionnaire
        case .completedV2SymptomsQuestionnaireAndStayAtHome: return \.completedV2SymptomsQuestionnaireAndStayAtHome
        case .hasCompletedV2SymptomsQuestionnaireBackgroundTick: return \.hasCompletedV2SymptomsQuestionnaireBackgroundTick
        case .hasCompletedV2SymptomsQuestionnaireAndStayAtHomeBackgroundTick: return \.hasCompletedV2SymptomsQuestionnaireAndStayAtHomeBackgroundTick
        }
    }
    
}
