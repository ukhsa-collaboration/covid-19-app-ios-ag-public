//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public enum Metric: String, CaseIterable {
    case backgroundTasks
    case completedOnboarding
    case checkedIn
    case deletedLastCheckIn
    case completedQuestionnaireAndStartedIsolation
    case completedQuestionnaireButDidNotStartIsolation
    case receivedPositiveTestResult
    case receivedNegativeTestResult
    case receivedVoidTestResult
    case contactCaseBackgroundTick
    case selfDiagnosedBackgroundTick
    case testedPositiveBackgroundTick
    case isolatedForSelfDiagnosedBackgroundTick
    case isolatedForTestedPositiveBackgroundTick
    case isolatedForHadRiskyContactBackgroundTick
    case isolatedForUnconfirmedTestBackgroundTick
    case indexCaseBackgroundTick
    case isolationBackgroundTick
    case pauseTick
    case runningNormallyTick
    case receivedVoidTestResultEnteredManually
    case receivedPositiveTestResultEnteredManually
    case receivedNegativeTestResultEnteredManually
    case receivedVoidTestResultViaPolling
    case receivedPositiveTestResultViaPolling
    case receivedNegativeTestResultViaPolling
    case receivedRiskyContactNotification
    case startedIsolation
    case receivedActiveIpcToken
    case haveActiveIpcTokenBackgroundTick
    case selectedIsolationPaymentsButton
    case launchedIsolationPaymentsApplication
    case totalExposureWindowsNotConsideredRisky
    case totalExposureWindowsConsideredRisky
    case hasTestedLFDPositiveBackgroundTick
    case isIsolatingForTestedLFDPositiveBackgroundTick
    
    case receivedPositiveLFDTestResultViaPolling
    case receivedNegativeLFDTestResultViaPolling
    case receivedVoidLFDTestResultViaPolling
    case receivedPositiveLFDTestResultEnteredManually
    case receivedNegativeLFDTestResultEnteredManually
    case receivedVoidLFDTestResultEnteredManually
    case receivedUnconfirmedPositiveTestResult
    
    case receivedPositiveSelfRapidTestResultEnteredManually
    case isIsolatingForTestedSelfRapidPositiveBackgroundTick
    case hasTestedSelfRapidPositiveBackgroundTick
    
    case acknowledgedStartOfIsolationDueToRiskyContact
    case hasRiskyContactNotificationsEnabledBackgroundTick
    case totalRiskyContactReminderNotifications
    
    case launchedTestOrdering
    
    case didAskForSymptomsOnPositiveTestEntry
    case didHaveSymptomsBeforeReceivedTestResult
    case didRememberOnsetSymptomsDateBeforeReceivedTestResult
    case declaredNegativeResultFromDCT
    
    case receivedRiskyVenueM1Warning
    case receivedRiskyVenueM2Warning
    case hasReceivedRiskyVenueM2WarningBackgroundTick
    
    // MARK: Key sharing invitations/completions
    
    case askedToShareExposureKeysInTheInitialFlow
    case consentedToShareExposureKeysInTheInitialFlow
    
    case totalShareExposureKeysReminderNotifications
    case consentedToShareExposureKeysInReminderScreen
    
    case successfullySharedExposureKeys
    
    // MARK: - Local Information / VOC
    
    case didSendLocalInfoNotification
    case didAccessLocalInfoScreenViaNotification
    case didAccessLocalInfoScreenViaBanner
    case isDisplayingLocalInfoBackgroundTick
    
}

public enum Metrics {
    static let category = "AppMetrics"
    
    static func begin(_ metric: Metric) {
        MetricCollector.record(metric)
    }
    
    static func end(_ metric: Metric) {}
    
    public static func signpost(_ metric: Metric) {
        MetricCollector.record(metric)
    }
    
    private static func signpostReceived(_ testResult: VirologyTestResult.TestResult, requiresConfirmatoryTest: Bool) {
        switch testResult {
        case .positive:
            signpost(.receivedPositiveTestResult)
            if requiresConfirmatoryTest {
                signpost(.receivedUnconfirmedPositiveTestResult)
            }
        case .negative:
            signpost(.receivedNegativeTestResult)
        case .void:
            signpost(.receivedVoidTestResult)
        case .plod:
            break
        }
        
    }
    
    static func signpostReceivedFromManual(
        testResult: VirologyTestResult.TestResult,
        testKitType: VirologyTestResult.TestKitType,
        requiresConfirmatoryTest: Bool
    ) {
        
        Self.signpostReceived(testResult, requiresConfirmatoryTest: requiresConfirmatoryTest)
        
        switch testKitType {
        case .rapidResult:
            switch testResult {
            case .positive:
                signpost(.receivedPositiveLFDTestResultEnteredManually)
            case .negative:
                signpost(.receivedNegativeLFDTestResultEnteredManually)
            case .void:
                signpost(.receivedVoidLFDTestResultEnteredManually)
            case .plod: break
            }
        case .rapidSelfReported:
            switch testResult {
            case .positive:
                signpost(.receivedPositiveSelfRapidTestResultEnteredManually)
            case .negative, .void, .plod:
                break
            }
        case .labResult:
            switch testResult {
            case .positive:
                signpost(.receivedPositiveTestResultEnteredManually)
            case .negative:
                signpost(.receivedNegativeTestResultEnteredManually)
            case .void:
                signpost(.receivedVoidTestResultEnteredManually)
            case .plod: break
            }
        }
        
    }
    
    static func signpostReceivedViaPolling(
        testResult: VirologyTestResult.TestResult,
        testKitType: VirologyTestResult.TestKitType,
        requiresConfirmatoryTest: Bool
    ) {
        
        Self.signpostReceived(testResult, requiresConfirmatoryTest: requiresConfirmatoryTest)
        
        switch testKitType {
        case .labResult:
            switch testResult {
            case .positive:
                signpost(.receivedPositiveTestResultViaPolling)
            case .negative:
                signpost(.receivedNegativeTestResultViaPolling)
            case .void:
                signpost(.receivedVoidTestResultViaPolling)
            case .plod: break
            }
        case .rapidResult:
            switch testResult {
            case .positive:
                signpost(.receivedPositiveLFDTestResultViaPolling)
            case .negative:
                signpost(.receivedNegativeLFDTestResultViaPolling)
            case .void:
                signpost(.receivedVoidLFDTestResultViaPolling)
            case .plod: break
            }
        case .rapidSelfReported:
            break
        }
        
    }
    
}
